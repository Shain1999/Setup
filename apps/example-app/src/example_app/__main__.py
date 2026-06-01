from example_core import greeting

from example_app.config import load_config


def main() -> None:
    config = load_config()
    print(greeting(config.name))


if __name__ == "__main__":
    main()
