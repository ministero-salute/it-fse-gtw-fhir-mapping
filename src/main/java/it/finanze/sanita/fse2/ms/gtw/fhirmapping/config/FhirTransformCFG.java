package it.finanze.sanita.fse2.ms.gtw.fhirmapping.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.enums.TransformALGEnum;
import lombok.Data;


@Data
@Component
public class FhirTransformCFG {

	@Value("${fhir.transform.alg}")
	private TransformALGEnum algToRemoveDuplicate;
}
