process bam_compare {
    tag "${stemName}"

    // Process settings label
    label 'deepTools'

    // Resources labels
    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    // Publish data
    publishDir(
        path:    "${params.publishDirData}/coverage",
        mode:    "${params.publishMode}",
        pattern: "${stemName}.bw"
    )

    input:
        tuple val(metadata), path(chipBam), path(chipBai), path(controlBam), path(controlBai)

    output:
        tuple val(metadata), path('*.bw'), emit: coverageBigWig

    script:
        String args = new Args(task.ext).buildArgsString()
        stemName = MetadataUtils.buildStemName(metadata)

        """
        bamCompare \\
            --bamfile1 ${chipBam} \\
            --bamfile2 ${controlBam} \\
            --outFileName ${stemName}.bw \\
            --outFileFormat bigwig \\
            --numberOfProcessors ${task.cpus} \\
            ${args}
        """
}
