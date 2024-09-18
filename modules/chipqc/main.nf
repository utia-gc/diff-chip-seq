process chipqc {
    // Process settings label
    label 'chipqc'

    // Resources labels
    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    // Publish data
    publishDir(
        path:    "${params.publishDirReports}/.chip",
        mode:    "${params.publishMode}",
        pattern: "ChIPQCreport"
    )

    input:
        path experimentCSV
        path dataFiles

    output:
        path 'ChIPQCreport', emit: chipqcReport

    script:
        // set arguments to supply to `ChIPQC()`
        String chipqcConstructorArgs = (task.ext.chipqcConstructorArgs) ? "'${experimentCSV}', ${task.ext.chipqcConstructorArgs}" : "'${experimentCSV}'"
        // set arguments to supply to `ChIPQCreport()`
        String chipqcReportArgs      = (task.ext.chipqcReportArgs) ?: ''

        """
        #!/usr/bin/env Rscript --vanilla

        library(ChIPQC)
        
        ChIPQC(${chipqcConstructorArgs}) |> 
            ChIPQCreport(${chipqcReportArgs})
        """
}
