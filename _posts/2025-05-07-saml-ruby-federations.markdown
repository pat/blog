---
title: "SAML and Ruby: Parsing federation metadata"
categories:
  - ruby
  - rails
  - sso
  - saml
excerpt: "When working with multiple IdPs, parsing metadata files is not performant via the ruby-saml gem - but there is a better way with Nokogiri."
---

*This post is part of the broader series around [SAML and Ruby](/2025/05/11/saml-ruby-collection.html).*

As part of rolling out SSO for our customers at [Covidence](https://www.covidence.org), we were quickly made aware of various federations that exist for research-related institutions (such as [AAF](https://aaf.edu.au) and [eduGAIN](https://edugain.org)) - and these federations collect both SAML identity and service provider metadata into central locations.

There's a great advantage in this for us - instead of needing to ask each of our customers individually for their SAML IdP metadata, we can instead just refer to these aggregated files. The catch? We need to parse those files just for what's relevant to us - and the files can get quite large!

Still, the [ruby-saml gem](https://github.com/SAML-Toolkits/ruby-saml) gives us a way to do this:

```ruby
def saml_settings
  parser = OneLogin::RubySaml::IdpMetadataParser.new

  settings = parser.parse_remote(
    # The aggregate metadata URL:
    "https://example.com/auth/saml2/idp/metadata",
    # The specific IdP we're looking for:
    entity_id: "http//example.com/target/entity"
  )

  # You've got the IdP settings, but you still need to add
  # the content of your service provider:
  settings.assertion_consumer_service_url =
    "http://#{request.host}/saml_sessions"

  settings
end
```

Now, the above example would involve downloading the metadata file every time you're generating settings for a SAML request - which definitely not a wise move. I recommend caching the settings for each specific identity provider you care about.

But also: parsing large files is very slow, and very memory hungry. We dug into the source code of the ruby-saml gem and found it's using [rexml](https://github.com/ruby/rexml) for the parsing. After some experimentation, we found a faster way with [Nokogiri](https://nokogiri.org):

```ruby
def saml_settings_hash(metadata_file_contents, entity_id)
  entire_document = Nokogiri::XML(
    metadata_file_contents
  )

  # Use Nokogiri to find the appropriate XML node:
  node = entire_document.xpath(
    "//md:EntityDescriptor[@entityID=\"#{entity_id}\"]/md:IDPSSODescriptor",
    "md" => "urn:oasis:names:tc:SAML:2.0:metadata"
  ).first
  return nil if node.nil?

  # Convert the IdP element into a standalone XML document,
  # so rexml can parse it:
  idp_document = Nokogiri::XML(node.to_xml).tap do |sub_document|
    entire_document.namespaces.each do |prefix, url|
      sub_document.root.add_namespace(normalised_prefix(prefix), url)
    end
  end

  # Return a hash that can be ingested by OneLogin::RubySaml::Settings
  OneLogin::RubySaml::IdpMetadataParser::IdpMetadata.new(
    REXML::Document.new(idp_document.to_xml).root,
    entity_id
  ).to_hash(
    sso_binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
  )
end

def normalised_prefix(prefix)
  return nil if prefix == "xmlns"

  prefix.gsub("xmlns:", "")
end
```

There's still room for improvement here - it'd be nice to avoid parsing the entire document - but it's not been a priority for us. The Nokogiri approach works well enough for now.

And I'm afraid we don't have any benchmarks on hand, so you'll just have to take my word for it! Granted, if you're digging into this and do have some numbers, please send them my way.
