package org.terrakube.api.plugin.scheduler.job.tcl.executor;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class TerraformVariable {
    private String key;
    private String value;
    private boolean hcl;
}
