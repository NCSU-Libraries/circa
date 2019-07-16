module InvoicesHelper

  def to_adderess
    if @custom_to
      output = @custom_to.html_safe
      else
        output = @user.display_name + '<br>'

        if !@user.address1.blank?
          output += @user.address1 + '<br>'
        end

        if !@user.address2.blank?
          output += @user.address2 + '<br>'
        end

        if !@user.city.blank?
          output += @user.city

          if !@user.state.blank?
            output += ', ' + @user.state
          end

          if !@user.zip.blank?
            output += '  ' + @user.zip
          end
        end


        if !@user.country.blank? && @user.country != 'US'
          countries = YAML.load File.read('lib/yaml/countries.yml')
          country = countries['countries'][@user.country]
          if country
            output += '<br>' + country
          end
        end


        if !@user.phone.blank?
          output += '<br>' + @user.phone
        end
        if !@user.email.blank?
          output += '<br><em>' + @user.email + '</em>'
        end
      end
      output.html_safe
  end

end
