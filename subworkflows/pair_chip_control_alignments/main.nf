/**
 * Pair up ChIP alignments with their matched Control alignments.
 *
 * @take alignments A channel of alignments with shape [ metadata, bam, bai ]
 *
 * @emit pairedChIPControlAlignments A channel of paired alignments with shape [ metadata, chipBam, chipBai, controlBam, controlBai ]
 */
workflow Pair_ChIP_Control_Alignments {
    take:
        alignments

    main:
        alignments
          | separateChIPControlAlignments
          | pairChIPControlAlignments
          | set { ch_pairedChIPControlAlignments }

    emit:
        pairedChIPControlAlignments = ch_pairedChIPControlAlignments
}


/**
 * Pair up ChIP alignments with their matched Control alignments.
 *
 * @param chipAlignments A channel of alignments with shape [ metadata, bam, bai ]
 * @param controlAlignments A channel of alignments with shape [ metadata, bam, bai ]
 *
 * @return A channel of paired alignments with shape [ metadata, chipBam, chipBai, controlBam, controlBai ]
 */
def pairChIPControlAlignments(chipAlignments, controlAlignments) {
    chipAlignments
        // pair chip and control datasets
        .join(
            controlAlignments
        )
        // get rid of grouping key and combine metadata
        .map { mappingsGroupKey, chipMeta, chipBam, chipBai, controlMeta, controlBam, controlBai ->
            return [
                // combine metadata
                MetadataUtils.intersectListOfMetadata([chipMeta, controlMeta]),
                chipBam,
                chipBai,
                controlBam,
                controlBai
            ]
        }
}


/**
 * Separate a mix of alignments into channels of ChIP alignments and Control alignments
 *
 * @param alignments A channel of alignments with shape [ metadata, bam, bai ]
 *
 * @return Two channels of ChIP alignments and Control alignments, each with shape [ metadata, bam, bai ]
 */
def separateChIPControlAlignments(alignments) {
    // Pair ChIP and control samples for each sampleName - target - controlType - replica pair
    alignments
        // separate into chip and control channels
        .branch { metadata, bam, bai ->
            chip: metadata.mode == "chip"
                def meta = metadata.clone()
                meta.remove('mode')
                return [ buildPairChIPControlGroupKey(metadata), meta, bam, bai ]

            control: metadata.mode == "control"
                def meta = metadata.clone()
                meta.remove('mode')
                return [ buildPairChIPControlGroupKey(metadata), meta, bam, bai ]
        }
}


String buildPairChIPControlGroupKey(metadata) {
    // the grouping key beings with the sample name
    ArrayList pairGroupKeyComponents = [metadata.sampleName]

    // if the sample metadata contains all the chip information, add it
    // don't add mode since this would prevent chip and control samples from having a common key
    if (metadata.target) pairGroupKeyComponents += metadata.target
    if (metadata.controlType) pairGroupKeyComponents += "${metadata.controlType}-control"
    if (metadata.replicate) pairGroupKeyComponents += "rep${metadata.replicate}"

    return pairGroupKeyComponents.join('_')
}

