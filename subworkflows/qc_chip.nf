include { multiqc as multiqc_chip } from "../modules/multiqc.nf"
include { multi_bam_summary       } from '../modules/deeptools/multiBamSummary'
include { plot_correlation        } from '../modules/deeptools/plotCorrelation'
include { plot_pca                } from '../modules/deeptools/plot_pca'


workflow QC_ChIP {
    take:
        alignmentsFiltered
        peaksLog

    main:
        collectBamsBais(alignmentsFiltered)
            .set { ch_collectedBamsBais }

        multi_bam_summary(ch_collectedBamsBais)
        ch_binsCoverageMatrix = multi_bam_summary.out.coverageMatrix

        plot_pca(ch_binsCoverageMatrix)
        plot_correlation(ch_binsCoverageMatrix)

        ch_multiqcChIP = Channel.empty()
            .concat( peaksLog.map { metadata, peakLog -> peakLog } )
            .concat( plot_pca.out.pcaData )
            .concat( plot_correlation.out.correlationData )
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


def collectBamsBais(alignments) {
    alignments
        .map { metadata, bam, bai ->
            return [ bam, bai ]
        }
        .collect(
            flat: false,
            sort: { a, b ->
                a[0].name <=> b[0].name
            }
        )
        .transpose()
        .collect(flat: false)
}
