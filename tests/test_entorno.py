"""Humo del entorno: si falla, la imagen o el venv estan rotos, no el producto."""


def test_imports_base():
    import fastapi  # noqa: F401
    import numpy  # noqa: F401
    import pandas  # noqa: F401
    import streamlit  # noqa: F401
