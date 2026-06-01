from example_core import greeting


def test_greeting() -> None:
    assert greeting("world") == "Hello, world!"
