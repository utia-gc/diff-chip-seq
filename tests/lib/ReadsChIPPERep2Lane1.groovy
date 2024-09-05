import groovy.transform.InheritConstructors

@InheritConstructors
class ReadsChIPPERep2Lane1 extends Reads {
    LinkedHashMap metadata = [
        sampleName:   'wt_ip1',
        lane:         '001',
        rep:          '2',
        target:       'FLAG-IP1',
        readType:     'paired',
        mode:         'chip',
        controlType:  'input',
    ]
    List reads = [
        "tests/data/reads/raw/wt_antiflag_ip1_rep2_S1_L001_R1_001.fastq.gz",
        "tests/data/reads/raw/wt_antiflag_ip1_rep2_S1_L001_R2_001.fastq.gz"
    ]
}
