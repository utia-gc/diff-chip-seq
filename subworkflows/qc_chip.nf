include { ChIPQC                       } from "../subworkflows/chipqc"
include { Pair_ChIP_Control_Alignments } from '../subworkflows/pair_chip_control_alignments'
include { Summarize_DeepTools          } from "../subworkflows/summarize_deeptools"
include { bam_compare                  } from '../modules/deeptools/bamCompare'
include { bam_coverage                 } from '../modules/deeptools/bamCoverage'
include { multiqc as multiqc_chip      } from "../modules/multiqc.nf"
include { phantompeakqualtools         } from '../modules/phantompeakqualtools'


workflow QC_ChIP {
    take:
        alignmentsFiltered
        peaksLog

    main:
        bam_coverage(alignmentsFiltered)

        // pair ChIP samples with their Controls
        Pair_ChIP_Control_Alignments(alignmentsFiltered)
        ch_pairedChIPControlAlignments = Pair_ChIP_Control_Alignments.out.pairedChIPControlAlignments
        bam_compare(ch_pairedChIPControlAlignments)

        phantompeakqualtools(ch_pairedChIPControlAlignments)

        Summarize_DeepTools(alignmentsFiltered)
        ch_pcaData         = Summarize_DeepTools.out.pcaData
        ch_correlationData = Summarize_DeepTools.out.correlationData

        ChIPQC(
            alignmentsFiltered,
            peaksLog
        )

        ch_multiqcChIP = Channel.empty()
            .concat( peaksLog.map { metadata, peakLog -> peakLog } )
            .concat( phantompeakqualtools.out.sppOut.map { metadata, sppOut -> sppOut } )
            .concat( ch_pcaData )
            .concat( ch_correlationData )
            .collect(
                // sort based on file name
                sort: { a, b ->
                    a.name <=> b.name
                }
            )

        multiqc_chip(
            ch_multiqcChIP,
            file("${projectDir}/assets/multiqc_config.yaml"),
            'chip'
        )

    emit:
        multiqc = ch_multiqcChIP
}
