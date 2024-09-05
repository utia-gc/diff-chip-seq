import groovy.transform.InheritConstructors

@InheritConstructors
class ReadsInputPERep1Lane1 extends Reads {
    LinkedHashMap metadata = [
        sampleName:   'wt_ip1',
        lane:         '001',
        rep:          '1',
        target:       'FLAG-IP1',
        readType:     'paired',
        mode:         'control',
        controlType:  'input',
    ]
    List reads = [
        "tests/data/reads/raw/wt_input_ip1_rep1_S1_L001_R1_001.fastq.gz",
        "tests/data/reads/raw/wt_input_ip1_rep1_S1_L001_R2_001.fastq.gz"
    ]
}
