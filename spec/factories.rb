FactoryGirl.define do


  factory :search_index do

  end


  factory :course_reserve, :class => 'CourseReserve' do

  end


  factory :item_catalog_record do

  end


  factory :order_user do

  end


  factory :user_access_session do

  end


  factory :access_session do
    start_datetime DateTime.now
    end_datetime DateTime.now
  end


  factory :order do
    access_date_start Date.today

    after(:create) do |order|
      ot = OrderType.create(name: 'test', label: 'test')
      ost = OrderSubType.create(name: 'test', label: 'test', order_type_id: ot.id)
      location = create(:location)
      order.update_attributes(location_id: location.id, order_sub_type_id: ost.id)
      order.reload
    end

    factory :order_with_user_and_assignee do
      after(:create) do |order|
        user = create(:user_with_role)
        OrderUser.create(user_id: user.id, order_id: order.id)

        assignee = create(:user_with_role)
        OrderAssignment.create(user_id: assignee.id, order_id: order.id)
      end
    end

    factory :order_with_items do
      transient do
        item_count 3
      end
      after(:create) do |order, evaluator|
        create_list(:item, evaluator.item_count).each do |i|
          ItemOrder.create(item_id: i.id, order_id: order.id)
        end
      end
    end

    factory :order_with_digital_item do
      after(:create) do |order, evaluator|
        i = Item.create(uri: '/fake/uri', digital_object: true)
        ItemOrder.create(item_id: i.id, order_id: order.id)
      end
    end

  end


  factory :user_role do
    sequence( :name ) { |n| "test#{n}" }
    sequence( :level ) { |n| (n + 1) * 10 }
  end


  factory :user do
    first_name "Don"
    last_name "Ho"
    sequence( :email ) { |n| "person#{n}@example.com" }
    password Devise::Encryptor.digest(User, 'password')
    agreement_confirmed_at Time.now
    user_role_id { create(:user_role).id }

    factory :user_with_role do
      after(:create) do |user|
        if !user.user_role_id
          test_role = UserRole.find_by_name('test') || create(:user_role)
          user.update_attributes(user_role_id: test_role.id)
        end
      end
    end


    factory :user_with_orders do
      transient do
        orders_count 3
      end
      after(:create) do |user, evaluator|
        create_list(:order, evaluator.orders_count).each do |r|
          OrderUser.create(user_id: user.id, order_id: r.id)
        end
      end
    end

    factory :user_with_assigned_orders do
      transient do
        orders_count 3
      end
      after(:create) do |user, evaluator|
        create_list(:order, evaluator.orders_count).each do |r|
         OrderAssignment.create(user_id: user.id, order_id: r.id)
        end
      end
    end

    factory :admin_user do
      after(:create) do |user, evaluator|
        admin_role = UserRole.find_by_name('admin')
        if !admin_role
          admin_role = UserRole.create(name:'admin', level: 1)
        end
        user.update_attributes(user_role_id: admin_role.id)
      end
    end

  end


  factory :item do
    sequence( :uri ) { |n| "/repositories/2/resources/1234/box/#{n}" }
  end


  factory :location do
    sequence( :uri ) { |n| "/repositories/2/resources/1234#{n}" }
    source_id Location.archivesspace_location_source_id
  end


  factory :note do
    content "Mr Leopold Bloom ate with relish the inner organs of beasts and fowls."
  end


  factory :item_order do
  end


  factory :digital_image_order do
    sequence( :image_id ) { |n| "image#{n}" }
    requested_images [ 'imagefile0001', 'imagefile0002', 'imagefile0003' ]
    sequence(:label) { |n| "Digital image order #{n}" }
  end

end
