/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;

@Component
public class ProfileUtility {
    @Autowired
    private Environment environment;

    public boolean isTestProfile() {
        if (environment != null && environment.getActiveProfiles().length > 0) {
            return environment.getActiveProfiles()[0].toLowerCase().contains(Constants.Profile.TEST);
        }
        return false;
    }
}
