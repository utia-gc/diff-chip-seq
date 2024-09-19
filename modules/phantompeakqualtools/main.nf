process phantompeakqualtools {
    tag "${stemName}"

    // Process settings label
    label 'phantompeakqualtools'

    // Resources labels
    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    input:
        tuple val(metadata), path(chipBam), path(chipBai), path(controlBam), path(controlBai)

    output:
        tuple val(metadata), path("${stemName}.spp.out"), emit: sppOut

    script:
        String args = new Args(task.ext).buildArgsString()
        stemName = MetadataUtils.buildStemName(metadata)

        """
        Rscript --vanilla \\
            /usr/local/bin/run_spp.R \\
            -c=${chipBam} \\
            -i=${controlBam} \\
            -out=${stemName}.spp.out \\
            ${args}
        """
}
