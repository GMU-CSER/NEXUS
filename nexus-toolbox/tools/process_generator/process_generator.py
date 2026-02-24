#!/usr/bin/env python3
"""
Nexus Process Generator Tool

Adapted from CATChem Process Generator.
Includes support for HEMCO extensions.
"""
import argparse
import logging
import os
import yaml
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Any, Optional, Union
from jinja2 import Environment, FileSystemLoader, select_autoescape
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger('ProcessGenerator')

@dataclass
class SchemeConfig:
    name: str
    class_name: str
    description: str
    author: str = ""
    required_met_fields: List[str] = field(default_factory=list)

@dataclass
class ProcessConfig:
    name: str
    class_name: str
    description: str
    author: str
    version: str = "1.0.0"
    process_type: str = "nexus_process" # nexus_process or hemco_extension
    species: List[str] = field(default_factory=list)
    schemes: List[SchemeConfig] = field(default_factory=list)
    default_scheme: str = ""
    output_dir: str = ""

class ProcessGenerator:
    def __init__(self, template_dir: Optional[str] = None):
        if template_dir is None:
            template_dir = str(Path(__file__).parent / "templates")
        self.template_dir = Path(template_dir)
        self.env = Environment(
            loader=FileSystemLoader(str(self.template_dir)),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=True,
            lstrip_blocks=True
        )
        # Add custom filters
        self.env.filters['pascal_case'] = self._pascal_case

    @staticmethod
    def _pascal_case(s: str) -> str:
        """Convert string to PascalCase."""
        return ''.join(word.capitalize() for word in s.replace('_', ' ').replace('-', ' ').split())

    def load_config(self, config_path: Union[str, Path]) -> ProcessConfig:
        with open(config_path, 'r') as f:
            data = yaml.safe_load(f)

        p_data = data.get('process', {})
        s_data_list = data.get('schemes', [])

        schemes = []
        for s in s_data_list:
            schemes.append(SchemeConfig(**s))

        p_data['schemes'] = schemes
        return ProcessConfig(**p_data)

    def generate_process(self, config: ProcessConfig, output_dir: Optional[str] = None) -> None:
        if output_dir:
            base_dir = Path(output_dir)
        else:
            base_dir = Path(".")

        if config.process_type == "hemco_extension":
            self._generate_hemco_extension(config, base_dir)
        else:
            self._generate_nexus_process(config, base_dir)

    def _generate_nexus_process(self, config: ProcessConfig, base_dir: Path) -> None:
        proc_dir = base_dir / config.name
        schemes_dir = proc_dir / "schemes"
        unit_test_dir = proc_dir / "tests" / "unit"

        proc_dir.mkdir(parents=True, exist_ok=True)
        schemes_dir.mkdir(parents=True, exist_ok=True)
        unit_test_dir.mkdir(parents=True, exist_ok=True)

        templates = {
            "process_interface.F90.j2": f"Process{config.class_name}Interface_Mod.F90",
            "process_common.F90.j2": f"{config.class_name}Common_Mod.F90",
            "process_creator.F90.j2": f"{config.class_name}ProcessCreator_Mod.F90",
            "CMakeLists.txt.j2": "CMakeLists.txt",
            "process_documentation.md.j2": f"{config.name}.md"
        }

        for t_name, out_name in templates.items():
            t = self.env.get_template(t_name)
            content = t.render(config=config, timestamp=datetime.now().isoformat())
            with open(proc_dir / out_name, 'w') as f:
                f.write(content)

        # Schemes
        scheme_template = self.env.get_template("scheme_module.F90.j2")
        for scheme in config.schemes:
            content = scheme_template.render(config=config, scheme=scheme, timestamp=datetime.now().isoformat())
            out_name = f"{config.class_name}Scheme_{scheme.class_name}_Mod.F90"
            with open(schemes_dir / out_name, 'w') as f:
                f.write(content)

        # Schemes CMake
        schemes_cmake_t = self.env.get_template("schemes_CMakeLists.txt.j2")
        content = schemes_cmake_t.render(config=config, timestamp=datetime.now().isoformat())
        with open(schemes_dir / "CMakeLists.txt", 'w') as f:
            f.write(content)

        # Unit test
        test_template = self.env.get_template("unit_test.F90.j2")
        content = test_template.render(config=config, timestamp=datetime.now().isoformat())
        with open(unit_test_dir / f"test_{config.name}_unit.F90", 'w') as f:
            f.write(content)

        logger.info(f"Nexus process {config.name} generated in {proc_dir}")

    def _generate_hemco_extension(self, config: ProcessConfig, base_dir: Path) -> None:
        ext_dir = base_dir / f"hcox_{config.name.lower()}"
        ext_dir.mkdir(parents=True, exist_ok=True)

        template = self.env.get_template("hemco_extension.F90.j2")
        content = template.render(config=config, timestamp=datetime.now().isoformat())

        out_name = f"hcox_{config.name.lower()}_mod.F90"
        with open(ext_dir / out_name, 'w') as f:
            f.write(content)

        logger.info(f"HEMCO extension {config.name} generated in {ext_dir}")

def main():
    parser = argparse.ArgumentParser(description="Nexus Process Generator")
    subparsers = parser.add_subparsers(dest='command')

    gen_parser = subparsers.add_parser('generate')
    gen_parser.add_argument('--config', '-c', required=True)
    gen_parser.add_argument('--output', '-o')

    val_parser = subparsers.add_parser('validate')
    val_parser.add_argument('--config', '-c', required=True)

    args = parser.parse_args()

    generator = ProcessGenerator()

    if args.command == 'validate':
        generator.load_config(args.config)
        logger.info(f"Configuration {args.config} is valid.")
    elif args.command == 'generate':
        config = generator.load_config(args.config)
        generator.generate_process(config, args.output)

if __name__ == '__main__':
    main()
