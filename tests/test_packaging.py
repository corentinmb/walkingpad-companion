import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PackagingTests(unittest.TestCase):
    def run_script(self, name, args=(), env=None):
        return subprocess.run(["bash", str(ROOT / "scripts" / name), *args],
                              text=True, capture_output=True, env={**os.environ, **(env or {})})

    def test_build_rejects_invalid_configuration_before_creating_output(self):
        result = self.run_script("build-app.sh", ["invalid"])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("debug or release", result.stderr)

    def test_build_rejects_invalid_version_before_creating_output(self):
        result = self.run_script("build-app.sh", env={"WALKINGPAD_VERSION": "../../oops"})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("version", result.stderr.lower())

    def test_packaging_rejects_missing_app(self):
        with tempfile.TemporaryDirectory() as directory:
            result = self.run_script("package-dmg.sh", [str(Path(directory) / "missing.app")])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing app", result.stderr)

    def test_notarization_requires_explicit_keychain_profile(self):
        result = self.run_script("notarize.sh", env={"WALKINGPAD_NOTARY_PROFILE": ""})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("WALKINGPAD_NOTARY_PROFILE", result.stderr)


if __name__ == "__main__":
    unittest.main()
