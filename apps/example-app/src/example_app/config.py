"""App config: environment-driven settings with sane defaults."""

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Config:
    name: str
    debug: bool


def load_config() -> Config:
    return Config(
        name=os.environ.get("APP_NAME", "world"),
        debug=os.environ.get("APP_DEBUG", "false").lower() == "true",
    )
