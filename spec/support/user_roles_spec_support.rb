module UserRolesSpecSupport

  def populate_roles
    role_attributes = [
      ['admin', 1],
      ['test', 10]
    ]
    role_attributes.each do |a|
      if !UserRole.find_by_name(a[0])
        UserRole.create!(name: a[0], level: a[1])
      end
    end
  end

end
