class AddDataToState < ActiveRecord::Migration[6.1]
  def up
    %w[AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI
       MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VA WA WV WI WY].each do |state|
      State.where(name: state).first_or_create
    end
  end

  def down
    State.delete_all
  end
end
