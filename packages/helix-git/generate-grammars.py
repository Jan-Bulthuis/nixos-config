"""
Lock the tree-sitter grammars of a Helix languages.toml into grammars.json, in the
format nixpkgs' helix package takes as `lockedGrammars`.

Based on nixpkgs' pkgs/by-name/he/helix/generate_grammars.py, but each fetch gets a
timeout and falls back to fetching over git. Some forges (e.g. Codeberg) can hang
while generating archives.

Usage: generate-grammars.py <languages.toml> <grammars.json>
"""

import asyncio
import json
import os
import sys
import tomllib

TIMEOUT = 120


async def nurl(url, rev, *extra):
    proc = await asyncio.create_subprocess_exec(
        "nurl", *extra, url, rev, "--json",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    try:
        stdout, stderr = await asyncio.wait_for(proc.communicate(), TIMEOUT)
    except asyncio.TimeoutError:
        proc.kill()
        await proc.wait()
        raise RuntimeError(f"timed out after {TIMEOUT}s")
    if proc.returncode != 0:
        raise RuntimeError(stderr.decode().strip())
    return json.loads(stdout)


async def lock(grammar, semaphore):
    source = grammar["source"]
    async with semaphore:
        try:
            result = await nurl(source["git"], source["rev"])
        except RuntimeError as e:
            print(f"  {grammar['name']}: {e}, retrying over git", file=sys.stderr)
            result = await nurl(source["git"], source["rev"], "-f", "fetchgit")
    print(f"  locked {grammar['name']}", file=sys.stderr)
    return grammar["name"].replace("_", "-"), {
        "nurl": result,
        "subpath": source.get("subpath"),
    }


async def main(languages_toml, output):
    with open(languages_toml, "rb") as f:
        grammars = [
            g
            for g in tomllib.load(f).get("grammar", [])
            if "git" in g.get("source", {}) and "rev" in g["source"]
        ]
    print(f"Locking {len(grammars)} grammars", file=sys.stderr)

    semaphore = asyncio.Semaphore(os.cpu_count() or 4)
    results = await asyncio.gather(
        *(lock(g, semaphore) for g in grammars), return_exceptions=True
    )

    failed = [(g["name"], r) for g, r in zip(grammars, results) if isinstance(r, Exception)]
    if failed:
        for name, error in failed:
            print(f"failed: {name}: {error}", file=sys.stderr)
        sys.exit(1)

    with open(output, "w") as f:
        json.dump(dict(sorted(results)), f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    asyncio.run(main(*sys.argv[1:3]))
