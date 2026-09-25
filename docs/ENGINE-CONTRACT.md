# Engine contract (stable interface for the Kraskus Universal Miner)

Version: **1** (introduced with kraskus-kawpowminer 1.3.0). Any incompatible change bumps this
number and the engine's major version.

## Invocation

```
kawpowminer -P stratum+tcp://<WALLET>.<WORKER>:<PASSWORD>@<HOST>:<PORT> \
            --cuda-devices <n> [<n> ...] \
            --api-bind 127.0.0.1:<API_PORT> \
            --display-interval 10 --report-hashrate
```

| Element | Contract |
|---|---|
| Pool URL | `stratum+tcp://` or `stratum+ssl://` (TLS), `stratum1+tcp://`, `stratum2+tcp://` as upstream; user is `<WALLET>.<WORKER>`, password after `:`; IPv6 hosts in brackets. |
| Device selection | `--cuda-devices` takes CUDA ordinals. The Universal Miner sets `CUDA_DEVICE_ORDER=PCI_BUS_ID` for every launch and derives ordinals from PCI order, so ordinals are stable. At start the engine prints one line per selected device: `[kraskus] device <ordinal> pci <DDDDDDDD:BB:DD.F> uuid <GPU-...> name <...> cc <major>.<minor>` (implemented in 1.3.0; verified identical to `nvidia-smi` on the RTX 3070 Ti: `[kraskus] device 0 pci 00000000:01:00.0 uuid GPU-8debc260-17d3-e634-7c4a-b13863eb0be2 name NVIDIA GeForce RTX 3070 Ti cc 8.6`). |
| API | JSON-RPC 2.0 over TCP on `--api-bind host:port` (upstream `libapicore`): `miner_getstat1`, `miner_getstatdetail`, `miner_ping`, `miner_restart`, `miner_shutdown`. Bind only to `127.0.0.1` when launched by the Universal Miner (the runtime passes the address). No write methods are enabled unless `--api-password` is set. |
| Exit codes | `0` clean exit (SIGTERM / Ctrl-Break / `miner_shutdown`); non-zero on fatal errors. |
| Graceful stop | SIGTERM (Linux), Ctrl-Break to the process group (Windows): the miner closes the pool connection and exits `0` within 5 s. |
| Working directory | Any; the engine writes nothing except optional `--log` output. |
| Fee | none. |

## Stdout telemetry lines (`--no-color` is not needed; the runtime strips ANSI)

The following line shapes are stable and are what the Universal Miner's `stdout_regex` source
matches (see the manifest in the Universal Miner registry):

| Event | Line (regex, PCRE-ish) | Emits |
|---|---|---|
| speed (every `--display-interval` s) | `^ ?m [0-9:]+ kawpowminer [0-9]+:[0-9]+ A(?P<accepted>[0-9]+)(:R(?P<rejected>[0-9]+))?(:F(?P<failed>[0-9]+))? (?P<value>[0-9.]+) (?P<unit>[KMG]?)h - cu0 [0-9.]+` — observed: `m 13:26:04 kawpowminer 0:04 A4 35.27 Mh - cu0 35.27` (A = accepted, R = rejected, F = failed-verification counters since start) | `total_hashrate`, share counters |
| accepted | `\*\*Accepted` (line also contains the pool response time) | `share_accepted` |
| rejected | `\*\*Rejected` | `share_rejected` |
| new job | `Job: ` | `new_job` |
| connected | `Established connection to ` | `pool_connected` |
| fatal | `No usable mining devices`, `CUDA error`, `Unable to initialize`, `Authorization failed`, `Connection refused`, `DNS` — classification mapping lives in the manifest |

The exact wording is frozen by `test/contract/run.sh` (runs on a GPU host: version, device table, identity line, speed/job/DAG/NVRTC lines, CPU verification, `miner_getstat1`); 10/10 on the RTX 3070 Ti rig for 1.3.0. Additional lines observed and stable: `Generated DAG + Light in <n> ms`, `Pre-compiled period <n> CUDA ProgPow kernel for arch <cc>`, `Job: <8 hex>… Sol: 0x<nonce> found in <s> sec`, and the failure marker `GPU <n> gave incorrect result`.

## Config file

None required. All settings are command-line options. (Upstream supports none; a JSON config
is out of scope for contract v1.)

## Versioning

`MAJOR.MINOR.PATCH` numeric only (Kraskus workspace rule). `MAJOR` changes only with this
contract. The version string appears in `--version`, in the API `miner_getstatdetail`
(`software`), and in the release artefact names `kraskus-kawpowminer-<version>-<platform>.<ext>`.
