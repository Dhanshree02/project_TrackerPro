"""Turn the RBAC spreadsheet into the baseline JSON the API seeds."""

import json
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
XLSX = ROOT / "docs" / "TK I PMS I New Modules RBAC I V01.xlsx"
OUT = ROOT / "apps" / "backend" / "Modules" / "Rbac" / "rbac-baseline.json"

ROLE_NAMES = {
    "CEO": "CEO",
    "COO": "COO",
    "CTO": "CTO",
    "IT Admin": "IT Admin",
    "Accounts": "Accounts",
    "HR": "HR",
    "Sales Manger": "Sales Manager",
    "Sales team member": "Sales team member",
    "PMO (Project Management Office)": "PMO",
    "EM (Engagement Manager)": "EngagementManager",
    "R&D -Team member": "R&D - Team member",
    "SOC - Team Member": "SOC-Team Member",
    "SOC - Team Leader": "SOC-Team Leader",
    "SOC - Manager": "SOC-Manager",
    "SOC - Senior Manager": "SOC-Senior Manager",
    "SOC - HOD": "SOC-HOD",
    "Consulting -Team member": "Consulting-Team member",
    "Consulting - Team Leader": "Consulting-Team Leader",
    "Consulting - Manager": "Consulting-Manager",
    "Consulting - Senior Manager": "Consulting-Senior Manager",
    "Consulting - HOD": "Consulting-HOD",
    "Testing - Team Member": "Testing-Team Member",
    "Testing - Team Leader": "Testing-Team Leader",
    "Testing - Manager": "Testing-Manager",
    "Testing - Senior Manager": "Testing Senior Manager",
    "Testing - HOD": "Testing HOD",
    "Intern": "Intern",
}

ACCESS = {
    "No Access": [0, 0],
    "Read Only": [1, 0],
    "Read & Write": [1, 1],
    "All RWE": [1, 1],
}

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}


def col_row(ref: str) -> tuple[int, int]:
    col = "".join(ch for ch in ref if ch.isalpha())
    row = int("".join(ch for ch in ref if ch.isdigit()))
    number = 0
    for ch in col:
        number = number * 26 + (ord(ch) - 64)
    return number, row


def load_grid(path: Path) -> dict[tuple[int, int], str]:
    with zipfile.ZipFile(path) as workbook:
        shared = ET.fromstring(workbook.read("xl/sharedStrings.xml"))
        strings = [
            "".join((node.text or "") for node in item.findall(".//m:t", NS))
            for item in shared.findall("m:si", NS)
        ]
        sheet = ET.fromstring(workbook.read("xl/worksheets/sheet1.xml"))
    grid: dict[tuple[int, int], str] = {}
    for row in sheet.findall("m:sheetData/m:row", NS):
        for cell in row.findall("m:c", NS):
            column, row_number = col_row(cell.attrib["r"])
            value = cell.find("m:v", NS)
            if value is None or value.text is None:
                text = ""
            elif cell.attrib.get("t") == "s":
                text = strings[int(value.text)]
            else:
                text = value.text
            grid[(row_number, column)] = text
    for merge in sheet.findall("m:mergeCells/m:mergeCell", NS):
        start, end = merge.attrib["ref"].split(":")
        (c1, r1), (c2, r2) = col_row(start), col_row(end)
        text = grid.get((r1, c1), "")
        for row_number in range(r1, r2 + 1):
            for column in range(c1, c2 + 1):
                grid[(row_number, column)] = text
    return grid


def main() -> None:
    grid = load_grid(XLSX)
    roles = []
    for row in range(6, 40):
        label = grid.get((row, 1), "").strip()
        if not label:
            break
        roles.append((row, ROLE_NAMES[label]))

    leaves = []
    for column in range(3, 60):
        path = [grid.get((row, column), "").strip() for row in range(1, 6)]
        if not any(path):
            continue
        grants = {}
        for row, role_name in roles:
            raw = grid.get((row, column), "").strip() or "No Access"
            grants[role_name] = ACCESS[raw]
        leaves.append(
            {
                "module": path[0] or None,
                "submodule": path[1] or None,
                "subSubmodule": path[2] or None,
                "widget": path[3] or None,
                "tab": path[4] or None,
                "grants": grants,
            }
        )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        json.dumps({"version": "excel-v01", "leaves": leaves}, indent=2),
        encoding="utf-8",
    )
    print(f"wrote {len(leaves)} leaves for {len(roles)} roles to {OUT}")


if __name__ == "__main__":
    main()
