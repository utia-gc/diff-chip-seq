include { Pair_ChIP_Control_Alignments } from '../subworkflows/pair_chip_control_alignments'
include { khmer_unique_kmers           } from '../modules/khmer/unique_kmers'
include { macs3_callpeak               } from '../modules/macs3/callpeak'


workflow CALL_PEAKS {
    take:
        alignments
        genome
        replicates_strategy

    main:
        // compute effective genome size
        khmer_unique_kmers(genome)

        // pair ChIP samples with their Controls
        Pair_ChIP_Control_Alignments(alignments)

        switch( replicates_strategy.toUpperCase() ) {
            case 'INDIVIDUAL':
                ch_pairedChIPControlAlignments = Pair_ChIP_Control_Alignments.out.pairedChIPControlAlignments
                break

            case 'POOL':
                ch_pairedChIPControlAlignments = Pair_ChIP_Control_Alignments.out.pairedChIPControlAlignments
                    .map { meta, chipBam, chipBai, controlBam, controlBai ->
                        return [
                            buildPoolReplicatesGroupKey(meta),
                            meta,
                            chipBam,
                            chipBai,
                            controlBam,
                            controlBai
                        ]
                    }
                    .groupTuple()
                    .map { mappingsGroupKey, meta, chipBam, chipBai, controlBam, controlBai ->
                        return [
                            // combine metadata
                            MetadataUtils.intersectListOfMetadata(meta),
                            chipBam,
                            chipBai,
                            controlBam,
                            controlBai
                        ]
                    }
                break
        }

        // Perform peak calling
        macs3_callpeak(
            ch_pairedChIPControlAlignments,
            khmer_unique_kmers.out.uniqueKmers
        )
        ch_callPeaksLog = macs3_callpeak.out.callpeakLog

    emit:
        callPeaksLog = ch_callPeaksLog
}


String buildPoolReplicatesGroupKey(metadata) {
    // the grouping key begins with the sample name
    ArrayList pairGroupKeyComponents = [metadata.sampleName]

    // if the sample metadata contains all the chip information, add it
    // don't add mode since this would prevent chip and control samples from having a common key
    if (metadata.target) pairGroupKeyComponents += metadata.target
    if (metadata.controlType) pairGroupKeyComponents += "${metadata.controlType}-control"

    return pairGroupKeyComponents.join('_')
}
