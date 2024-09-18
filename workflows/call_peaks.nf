include { Pair_ChIP_Control_Alignments } from '../subworkflows/pair_chip_control_alignments'
include { khmer_unique_kmers           } from '../modules/khmer/unique_kmers'
include { macs3_callpeak               } from '../modules/macs3/callpeak'


workflow CALL_PEAKS {
    take:
        alignments
        genome

    main:
        // compute effective genome size
        khmer_unique_kmers(genome)

        // pair ChIP samples with their Controls
        Pair_ChIP_Control_Alignments(alignments)
        ch_pairedChIPControlAlignments = Pair_ChIP_Control_Alignments.out.pairedChIPControlAlignments

        // Perform peak calling
        macs3_callpeak(
            ch_pairedChIPControlAlignments,
            khmer_unique_kmers.out.uniqueKmers
        )
        ch_callPeaksLog = macs3_callpeak.out.callpeakLog

    emit:
        callPeaksLog = ch_callPeaksLog
}


