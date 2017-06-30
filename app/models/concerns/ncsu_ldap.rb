require 'active_support/concern'

module NCSULdap
  extend ActiveSupport::Concern

  included do


    def self.create_from_ldap(unity_id, options = {})
      user = User.find_by(unity_id: unity_id)
      if !user
        attributes = attributes_from_ldap(unity_id)
        if attributes
          attributes[:role] = options[:role]
          user = create!(attributes)
        end
      end
      user
    end


    # NCSU-specific
    def self.attributes_from_ldap(uid)
      uid.strip!

      map_attributes = lambda do |ldap_entry|

        puts ldap_entry.inspect

        unity_id = ldap_entry.uid[0]
        attributes = {
          unity_id: unity_id,
          email: "#{unity_id}@ncsu.edu",
          display_name: ldap_entry.displayname[0],
          first_name: ldap_entry.givenname[0],
          last_name: ldap_entry.sn[0],
          position: ldap_entry.respond_to?(:title) ? ldap_entry.title[0] : nil,
          affiliation: 'North Carolina State University',
          password: SecureRandom.hex(16),
          city: ldap_entry.respond_to?(:l) ? ldap_entry.l[0] : nil,
          state: ldap_entry.respond_to?(:st) ? ldap_entry.st[0] : nil,
          zip: ldap_entry.respond_to?(:postalcode) ? ldap_entry.postalcode[0] : nil,
          phone: ldap_entry.respond_to?(:telephonenumber) ? ldap_entry.telephonenumber[0] : nil
        }

        if ldap_entry[:registeredaddress] && ldap_entry[:registeredaddress][0]
          address_parts = ldap_entry[:registeredaddress][0].split('$').map { |p| p.strip }
          address_parts.pop
          attributes[:address1] = address_parts[0]
          attributes[:address2] = address_parts[1]
        end

        return attributes
      end

      # try unity ID first
      uid.gsub!(/\@[A-Za-z0-9]+\.[A-Za-z0-9]+$/,'')
      ldap_entry = CampusLdap.entry_by_unityid(uid)

      if ldap_entry
        attributes = map_attributes.call(ldap_entry)
      else
        # no results as unityID, try as email
        uid += '@ncsu.edu'
        ldap_entry = CampusLdap.entry_by_email(uid)
        if ldap_entry
          attributes = map_attributes.call(ldap_entry)
        else
          attributes = nil
        end
      end
      attributes
    end


    def update_from_ldap
      attributes = User.attributes_from_ldap(self.unity_id)
      if attributes
        update_attributes(attributes)
      end
    end


  end

end
