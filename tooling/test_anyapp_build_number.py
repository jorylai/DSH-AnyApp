import concurrent.futures
import json
from pathlib import Path
import tempfile
import unittest
from anyapp_build_number import reserve, LIMIT

class AnyAppBuildNumberTest(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name);self.pubspec=self.root/'pubspec.yaml';self.state=self.root/'cache'/'number.json'
        self.pubspec.write_text('name: dsh_app\nversion: 0.10.1+2026110905\n')
    def test_repeated_builds_exceed_the_shipped_code_even_without_editing_pubspec(self):
        self.assertEqual(reserve(self.pubspec,self.state),2026110906)
        self.assertEqual(reserve(self.pubspec,self.state),2026110907)
    def test_parallel_reservations_do_not_reuse_a_code(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
            values=list(pool.map(lambda _:reserve(self.pubspec,self.state),range(24)))
        self.assertEqual(sorted(values),list(range(2026110906,2026110930)))
    def test_explicit_downgrade_is_rejected_without_corrupting_state(self):
        reserve(self.pubspec,self.state)
        before=self.state.read_bytes()
        with self.assertRaises(ValueError):reserve(self.pubspec,self.state,2026110905)
        self.assertEqual(self.state.read_bytes(),before)
    def test_corrupt_reservation_is_not_reset(self):
        self.state.parent.mkdir();self.state.write_text('{broken')
        with self.assertRaises(ValueError):reserve(self.pubspec,self.state)
    def test_android_limit_never_wraps(self):
        self.state.parent.mkdir();self.state.write_text(json.dumps({'format':1,'last':LIMIT}))
        with self.assertRaises(ValueError):reserve(self.pubspec,self.state)

if __name__=='__main__':unittest.main()
