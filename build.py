import subprocess

import PyInstaller.__main__

if __name__ == '__main__':
    subprocess.run('bash makespec.sh', shell=True)
    spec_file = 'marginnote-extractor.spec'
    PyInstaller.__main__.run([
        spec_file,
        '--noconfirm',
    ])
