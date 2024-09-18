include { Pair_ChIP_Control_Alignments } from '../../subworkflows/pair_chip_control_alignments'
include { chipqc                       } from '../../modules/chipqc'


workflow ChIPQC {
    take:
        alignments
        peaks

    main:
        joinPairedAlignmentsWithPeaks(
            Pair_ChIP_Control_Alignments(alignments),
            peaks
        )
            .set { ch_jointPairedAlignmentsPeaks }

        ch_jointPairedAlignmentsPeaks
            .collectFile(
                name: 'samples.csv',
                newLine: true,
                seed: "SampleID,Factor,Replicate,bamReads,bamControl,ControlID,Peaks,PeakCaller",
            ) { metadata, chipBam, chipBai, controlBam, controlBai, peakCalls ->
                [
                    "${metadata.get('sampleName')}_${metadata.get('target')}_rep${metadata.get('replicate')}",
                    metadata.get('target', ''),
                    metadata.get('replicate', ''),
                    chipBam.getName(),
                    controlBam.getName(),
                    "${metadata.get('sampleName')}_${metadata.get('target')}_${metadata.get('controlType')}_rep${metadata.get('replicate')}",
                    peakCalls.getName(),
                    'macs'
                ].join(',')
            }
            .set { ch_chipqcExperimentCSV }

        ch_jointPairedAlignmentsPeaks
            .collect(
                { metadata, chipBam, chipBai, controlBam, controlBai, peakCalls ->
                    return [ chipBam, chipBai, controlBam, controlBai, peakCalls ]
                },
                sort: { a, b ->
                    a.name <=> b.name
                }
            )
            .set { ch_chipqcDataFiles }

        chipqc(
            ch_chipqcExperimentCSV,
            ch_chipqcDataFiles
        )
}


def joinPairedAlignmentsWithPeaks(pairedAlignments, peaks) {
    pairedAlignments
        .map { metadata, chipBam, chipBai, controlBam, controlBai ->
            return [
                MetadataUtils.buildPairChIPControlGroupKey(metadata),
                metadata,
                chipBam, 
                chipBai,
                controlBam, 
                controlBai
            ]
        }
        .join(
            peaks
                .map { metadata, peakCalls ->
                    return [
                        MetadataUtils.buildPairChIPControlGroupKey(metadata),
                        metadata,
                        peakCalls
                    ]
                }
        )
        .map { groupingKey, alignmentsMetadata, chipBam, chipBai, controlBam, controlBai, peaksMetadata, peakCalls ->
            return [
                MetadataUtils.intersectListOfMetadata([alignmentsMetadata, peaksMetadata]),
                chipBam,
                chipBai,
                controlBam,
                controlBai,
                peakCalls
            ]
        }
}
