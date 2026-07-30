import json
from pathlib import Path

from app.main import app


def main() -> None:
    backend_root = Path(__file__).resolve().parents[1]
    output = backend_root / "openapi-sprint1.json"
    output.write_text(
        json.dumps(app.openapi(), ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(output)


if __name__ == "__main__":
    main()
