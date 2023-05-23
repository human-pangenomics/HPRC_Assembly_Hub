ROOT = ..
include ${ROOT}/defs.mk


diff = diff -u

ensemblGff3ToBigEnsembl = ${BINDIR}/ensemblGff3ToBigEnsembl

test: chm13Test hprcTest chm13AnnoyingAttrsTest drosophilaEnsemblTest

chm13Test: mkdirs
	${ensemblGff3ToBigEnsembl} --ucsc-names input/GCA_009914755.4.gff3 output/$@.gp
	${diff} expected/$@.gp output/$@.gp

hprcTest: mkdirs
	${ensemblGff3ToBigEnsembl} input/GCA_018466835.1.gff3 output/$@.gp
	${diff} expected/$@.gp output/$@.gp

chm13AnnoyingAttrsTest: mkdirs
	${ensemblGff3ToBigEnsembl} input/GCA_009914755.4-attrs-in-desc.gff3 output/$@.gp
	${diff} expected/$@.gp output/$@.gp

drosophilaEnsemblTest: mkdirs
	${ensemblGff3ToBigEnsembl} input/dm.GCA_000001215.4.gff3 output/$@.gp
	${diff} expected/$@.gp output/$@.gp

mkdirs:
	@mkdir -p output

clean:
	rm -rf output
