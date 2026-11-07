from pathlib import Path
import hashlib,json,zipfile
root=Path('.');zpath=root/'release/FlashGamesCE-v9-preview.zip';sha=hashlib.sha256(zpath.read_bytes()).hexdigest();assert zpath.with_suffix('.zip.sha256').read_text().split()[0]==sha
with zipfile.ZipFile(zpath)as z:
 assert z.testzip() is None;names=z.namelist();assert len(names)==len(set(names))==75;assert sum(n.endswith('.8xp')for n in names)==2;assert sum(n.endswith('.8xv')for n in names)==65
 files={Path(n).name:z.read(n)for n in names};manifest=json.loads(files['manifest.json'])
 for n,d in manifest.items():
  b=files[n];assert len(b)==d['bytes'] and hashlib.sha256(b).hexdigest()==d['sha256'];assert b[:11]==b'**TI83F*\x1a\x0a\0';assert sum(b[55:-2])&65535==int.from_bytes(b[-2:],'little');assert b[60:68].rstrip(b'\0').decode().casefold()==Path(n).stem.casefold()
 for line in files['SHA256SUMS.txt'].decode().splitlines():
  h,n=line.split('  ',1);assert hashlib.sha256(files[n]).hexdigest()==h
 assert not any(any(t in n.lower()for t in ['pedrodg','fill','native-ram','.rom','.bin','sctsv','pdprog','pdskytmp'])for n in files)
 v7=zipfile.ZipFile(root/'release/FlashGamesCE-v7-preview.zip');old={Path(n).name:v7.read(n)for n in v7.namelist()}
 assert all(files[n]==old[n] for n in files if n.endswith('.8xv') or n=='PEDROCE.8xp')
 p=Path('flash-ports/scoutcamp');meta=json.loads((p/'bin/build-metadata.json').read_text());assert hashlib.sha256(files['SCOUTCE.8xp']).hexdigest()==meta['program_sha256'];assert all(hashlib.sha256((p/'src'/n).read_bytes()).hexdigest()==h for n,h in meta['source_sha256'].items())
print('Validated75 ZIP members;2 programs;61 data banks +4 libraries; all hashes/checksums; unchanged Pedro/assets; exact Scouts source snapshot. ZIP',sha)

report=dict(zip=zpath.name,bytes=zpath.stat().st_size,sha256=sha,members=75,programs=2,data_appvars=61,libraries=4,zip_integrity=True,ti_checksums_and_internal_names=True,manifest_hashes=True,sha256sums=True,pedro_and_banks_equal_v7=True,scouts_build=meta,excluded=['ROM','raw RAM','saves','fillers','diagnostic and experimental programs'])
Path('flash-ports/verification/v9-package-validation.json').write_text(json.dumps(report,indent=2)+'\n')
