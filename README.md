# Implementation of an FPGA-based memory mapped buffer for real-time communication with a neuromorphic ASIC
BrainScaleS-2 is a mixed signal neuromorphic ASIC combining accelerated physical emulation of brain-inspired neurons and synapses with digital control logic. Experiments using the BrainScalesS-2 ASIC require real-time stimuli, since the analog emulation performed by the ASIC cannot be stopped and continued arbitrarily. This real-time communication is realized using an FPGA, while a conventional host computer controls the experiment. A buffer for the data to be sent to the ASIC and for data received from the ASIC is necessary in the FPGA, due to the mismatch of bandwidth to the host computer and the ASIC. The current buffer implementation has several limitations. It is not able to make use of all of the connected DRAM and the bandwidth of the buffer is smaller than the bandwidth between the FPGA and the ASIC for some cases, leading to nondeterministic timing that can reduce reproducibility.
This thesis presents a new design for this buffer that trades a lower maximum rate of experiments for the ability to use the full size of the available DRAM. The bandwidth is increased to always provide deterministic timing. Furthermore, the options for organization of data to be transmitted to and data received from the ASIC are extended to allow repeated use and sparse readout of data. Basic integration with the BSS-2 software stack was performed as well, that passes all unit and integration tests and transparently allows higher level software to use the new buffer.

# Entwicklung eines FPGA-basierten memory-mapped Zwischenspeicher für Echtzeit-Kommunikation mit einem neuromorphen ASIC
BrainScaleS-2 ist ein Mixed-Signal neuromorpher ASIC. Dabei wird beschleunigte, analoge Emulation von dem Hirn nachempfundenen von Neuronen und Synapsen mit digitaler Logik zur Konfiguration kombiniert.
Da der analoge Teil des ASIC nicht pausiert und wieder gestartet werden kann, setzt die Durchführung von Experimenten mit dem BrainScalesS-2 ASIC Echtzeit-Übertragung der Stimuli voraus.
Um diese Echtzeit-Übertragung für einen konventionellen Computer, der das Experiment durchführt, zu ermöglichen, wird ein FPGA verwendet.
Aufgrund der unterschiedlichen Bandbreiten zwischen Computer und ASIC wird ein Zwischenspeicher auf dem FPGA benötigt.
Die aktuelle Umsetzung dieses Zwischenspeicher hat den Nachteil, dass nicht der komplette an den FPGA angeschlossene Speicher ausgenutzt werden kann und in manchen Fällen die vom Zwischenspeicher erreichte Bandbreite kleiner ist als die Bandbreite zwischen ASIC und FPGA. Wenn diese Bandbreite nicht erreicht wird, kann die benötigte Echtzeit-Übertragung nicht garantiert werden und die Reproduzierbarkeit von Experimenten sinkt.
In dieser Arbeit wird eine neue Architektur für diesen Zwischenspeicher entwickelt und umgesetzt,
die die Ausnutzung des ganzen an den FPGA angebundenen DDR3 Speichers ermöglicht. Dabei ist die Bandbreite des Zwischenspeichers immer groß genug, um die Echtzeit-Übertragung zu garantieren. Zusätzlich wird wiederholtes Senden und partielles Auslesen der Daten ermöglicht.
Der einzige Nachteil der neuen Umsetzung ist eine Reduktion der maximal erreichten Anzahl an Experimenten die in einer bestimmten Zeit durchgeführt werden können. Vorschläge zur Verbesserung dieser Rate werden ebenfalls vorgestellt.
Die Programmbibliotheken die zur Durchführung von Experimenten verwendet werden wurden angepasst, sodass transparent für die Experimente der neue Zwischenspeicher verwendet wird.

# Reproduction
To generated the experimental data used in this thesis two parts are needed. The FPGA bitstream with the corresponding changes and the software changes working with the changed bitstream.

## FPGA bitstream
The changes required for the FPGA bitstream are

`hxfpga`:
- `Ic31ed629ff7d92a59053755ba3c4b6125694b9e0`
- `If92ea7f519299acf514667da6d244ebaf6f976ce`
- `I87807ac4d497eba4a2ea0ae80aa63ba9688985cf`
- `Ia29c666d88eb26dc20a741a14074a15063da4e1f`
- `I62baf9372190121186728010dc6c714d4394ac7b`
- `Ic46ab7a4ad97ff006a5ab9606b78fce3c7aa8dc9`
- `Ida2393ab5111a47f1710ce451a54590322c842d4`
- `I2a8b1a926333e8221a5e86a4f51b96b4443c822d`
`lib-vhdl-utils`: 
- `I040920155d9b651ea7796111a68fa23f3ce13449`
- `I472248e52f4a16841e2227626cf8d12dcba0826a`
`visionary-rtl-utils`:
- `Id9f35205596144fa719b223f6bb2dfa37abf60b9`
- `I68a653809a4632b00f1cd9497a5917f1ec0b979f`
- `Ica56e53d44b73177580d00cc869fee709c4858c5`
- `I56ecff5352246ca7026e3b9a3d205dac151ec069`

These changes can be found on [gerrit](http://gerrit.bioai.eu/).

## Software
Checkout the `hxcomm` project with the following changes:

`ayo`: 
- `Ie5012d8b575a63ee97225e3c8dcec0787d6ebc2f`
- `I179bcc7f516872180c18c4cb805138209f685a84`
- `Ic641d3bab02a69462b89c37889f91145134aa556`
`flange`:
- `If7780dd27375d4b073a63c3bc34cfd87ac23772f`
`halco`: 
- `I129931f8010b9c20dc87df361d393acfb1656785`
`haldls`:
- `I129931f8010b9c20dc87df361d393acfb1656785`
`hxcomm`:
- `Id5251a53698b4bf0a0a89c59971ae42c0b816caf`
- `I13bf5649f7adaa34058cc2b55c0db1449cdceb66`
- `I510a72e39edd2a3e05d315ebbe731deded89a763`

## Experiments
All experiments were used the `W60F0` or `W60F3` setup from a exclusive allocation of the `EpycHost1` node:
```bash
srun --mem=16G -c16 --nodelist=EpycHost1 --exclusive -p cube -t 48:00:00 --reservation nfiedler_101 --wafer 60 --fpga-without 0 --pty  bash
```
At the time of writing `W60F0` was equipped with a `HICANNXv2` and `W60F3` was equipped with a `HICANNXv3`

The following experiments were performed:
- `benchmark_ayo_bandwidth_vx_v2` measured the playback, trace and combined playback and trace bandwidth for different playback and trace buffer sizes in each descriptor
- `benchmark_ayo_bandwidth_stock` was executed once against the unmodified FPGA bitstream to measure the old playback, trace and combined bandwidth and once against the new bitstream 
- `measure_faxi_rtt` measured the rtt for different read and write targets of FAXI
- `measure_host_arq_bandwidth` measures the baseline bandwidth for sending and receiving data via Host-ARQ
- `benchmark_flange` measures the simulation performance for the JTAG-ID readout

`data/bandwidth_analysis.ipynb` is then used to analyze the data and produce the plots and values used in the thesis.

# PDF
You can find a compiled pdf of the thesis [here](./writeup.pdf) 
