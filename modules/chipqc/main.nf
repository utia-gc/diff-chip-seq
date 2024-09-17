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
        """
        #!/usr/bin/env Rscript --vanilla

        library(ChIPQC)
        
        ChIPQC("${experimentCSV}") |> 
            ChIPQCreport(${task.ext.chipqcReportArgs})
        """
}
