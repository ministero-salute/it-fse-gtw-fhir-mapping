package it.finanze.sanita.fse2.ms.gtw.fhirmapping;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.hl7.fhir.instance.model.api.IBaseBundle;
import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.instance.model.api.IIdType;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
import org.hl7.fhir.r4.model.DocumentReference;
import org.hl7.fhir.r4.model.IdType;

import ca.uhn.fhir.rest.api.MethodOutcome;
import ca.uhn.fhir.rest.client.api.IGenericClient;
import ca.uhn.fhir.rest.gclient.ICriterion;
import ca.uhn.fhir.rest.gclient.IHistory;
import ca.uhn.fhir.rest.gclient.IHistoryTyped;
import ca.uhn.fhir.rest.gclient.IQuery;
import ca.uhn.fhir.rest.gclient.IReadExecutable;
import ca.uhn.fhir.rest.gclient.IReadTyped;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.FHIRR4Helper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.StringUtility;

public class FHIRClient {

	private IGenericClient client;

	public FHIRClient(String serverURL) {
		Validation.notNull(serverURL);
		client = FHIRR4Helper.createClient(serverURL);
	}

	public Bundle getDocumentReference(String drID) {
		Validation.notNull(drID);
		return client
				   .search()
				   .forResource(DocumentReference.class)
				   .where(DocumentReference.IDENTIFIER.exactly().identifier(drID))
				   .returnBundle(Bundle.class)
				   .execute();
	}

	public Bundle saveBundleWithTransaction(Bundle bundle) {
		return client.transaction().withBundle(bundle).execute();
	}

	public List<IBaseResource> saveBundleAndDRWithTransaction(Bundle bundle, Bundle dr) {
	    return client.transaction().withResources(Arrays.asList((IBaseResource) bundle, (IBaseResource) dr)).execute();
	}

	public List<BundleEntryComponent> historyResource(Class<? extends IBaseResource> resourceClass, String id) {
		return historyResource(resourceClass, id, null, null);
	}

	public List<BundleEntryComponent> historyResource(Class<? extends IBaseResource> resourceClass, String id, Integer count) {
		return historyResource(resourceClass, id, count, null);
	}

	public List<BundleEntryComponent> historyResource(Class<? extends IBaseResource> resourceClass, String id, Date since) {
		return historyResource(resourceClass, id, null, since);
	}

	public List<BundleEntryComponent> historyResource(Class<? extends IBaseResource> resourceClass, String id, Integer count, Date since) {
		Validation.notNull(resourceClass, StringUtility.isNullOrEmpty(id));

		IHistory history = client.history();
		IHistoryTyped<Bundle> historyTyped = null;
		String resourceType = resourceClass.getSimpleName();
		IdType instance = new IdType(resourceType, id);
		historyTyped = history.onInstance(instance).returnBundle(Bundle.class);

		if (count != null) {
			historyTyped = historyTyped.count(count);
		}
		
		if (since != null) {
			historyTyped = historyTyped.since(since);
		}
		
		return historyTyped.execute().getEntry();
	}

	public IIdType deleteResource(Class<? extends IBaseResource> resourceClass, String id) {
		Validation.notNull(resourceClass, id);
		String resourceType = resourceClass.getSimpleName();
		MethodOutcome outcome = client.delete().resourceById(resourceType, id).execute();
		return outcome.getId();
	}

	public IIdType createResource(IBaseResource resource) {
		Validation.notNull(resource);
		MethodOutcome outcome = client.create().resource(resource).execute();
		if (!outcome.getCreated()) {
			throw new RuntimeException("FHIR RESOURCE NOT CREATED!");
		}
		return outcome.getId();
	}

	public List<BundleEntryComponent> getResources(Class<? extends IBaseResource> resourceClass, Integer count, ICriterion<?>...criterions) {
		Validation.notNull(resourceClass);
		IQuery<IBaseBundle> query = client.search().forResource(resourceClass);
		
		boolean first = true;
		for (ICriterion<?> criterion:criterions) {
			if (first) {
				query = query.where(criterion);
				first = false;
			} else {
				query = query.and(criterion);
			}
		}
		if (count!=null) {
			query = query.count(count);
		}
		return query.returnBundle(Bundle.class).execute().getEntry();
	}

	public IBaseResource getResource(Class<? extends IBaseResource> resourceClass, String id) {
		return getResource(resourceClass, id, null);
	}

	public IBaseResource getResource(Class<? extends IBaseResource> resourceClass, String id, String version) {
		Validation.notNull(resourceClass, id);
		IReadTyped<? extends IBaseResource> typedRead = client.read().resource(resourceClass);
		IReadExecutable<? extends IBaseResource> executable;
		if (StringUtility.isNullOrEmpty(version)) {
			executable = typedRead.withId(id);
		} else {
			executable = typedRead.withIdAndVersion(id, version);
		}
		return executable.execute();
	}

	public IBaseResource getResourceByUrl(Class<? extends IBaseResource> resourceClass, String url) {
		Validation.notNull(resourceClass, url);
		return client.read()
		   .resource(resourceClass)
		   .withUrl(url)
		   .execute();
	}

	public IIdType updateResource(IBaseResource resource) {
		Validation.notNull(resource, resource.getIdElement());
		MethodOutcome outcome = client.update().resource(resource).execute();
		return outcome.getId();
	}
	
}