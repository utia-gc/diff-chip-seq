include { multiqc as multiqc_chip } from "../modules/multiqc.nf"


workflow QC_ChIP {
    take:
        peaksLog

    main:
        ch_multiqcChIP = Channel.empty()
            .concat( peaksLog.map { metadata, peakLog -> peakLog } )
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
