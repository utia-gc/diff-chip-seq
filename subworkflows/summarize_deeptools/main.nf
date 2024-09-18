include { multi_bam_summary } from '../../modules/deeptools/multiBamSummary'
include { plot_correlation  } from '../../modules/deeptools/plotCorrelation'
include { plot_pca          } from '../../modules/deeptools/plotPCA'


/**
 * Run deepTools summary tools to create PCA and correlation plots.
 *
 * @take alignments A channel of alignments with shape [ metadata, bam, bai ]
 *
 * @emit pcaData The output PCA data file from deepTools `plotPCA --outFileNameData`
 * @emit correlationData The output correlation data file from deepTools `plotCorrelation --outFileCorMatrix`
 */
workflow Summarize_DeepTools {
    take:
        alignments

    main:
        collectBamsBais(alignments)
          | multi_bam_summary
          | ( plot_pca & plot_correlation )

    emit:
        pcaData         = plot_pca.out.pcaData
        correlationData = plot_correlation.out.correlationData
}


/**
 * Collect a channel with a BAM and a BAM index into a list of BAMs and BAM indexes
 *
 * Transforms a channel of shape [ metadata, bam, bai ] into a collection channel of shape [ [bams], [bais] ].
 * This is convenient for using as input to a process that takes a list of bams and requires their indexes.
 *
 * @param alignments A channel of alignments with shape [ metadata, bam, bai ]
 *
 * @return Collection channel of shape [ [bams], [bais] ].
 */
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
