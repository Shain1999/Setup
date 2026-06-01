from example_app.config import load_config


def test_load_config_defaults(monkeypatch) -> None:
    monkeypatch.delenv("APP_NAME", raising=False)
    monkeypatch.delenv("APP_DEBUG", raising=False)
    config = load_config()
    assert config.name == "world"
    assert config.debug is False
