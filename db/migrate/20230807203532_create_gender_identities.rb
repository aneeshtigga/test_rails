class CreateGenderIdentities < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :gender_identity, :string, null: false, default: "", if_not_exists: true,
    comment: <<~END_OF_COMMENT
      Gender Identity is Protected Health Information (PHI) according to
      Health Insurance Portability and Accountability Act of 1996 (HIPAA) 
      Privacy Rules. Specifically, HIPAA prohibits the disclosure of 
      protected health information about gender-affirming care without 
      consent except in limited circumstances. One of these limited 
      circumstances—where disclosure may be possible without a patient's 
      consent—is when disclosure is required under another law.
      <p><p>
      In therapy sessions, the term "gender identity" is commonly used to 
      refer to an individual's internal sense of their own gender, which 
      may or may not align with the sex they were assigned at birth. 
      Therapists may work with individuals to explore and understand 
      their gender identity, and to help them navigate any challenges or 
      difficulties they may face as a result of their gender identity. 
      This may involve discussing issues such as gender dysphoria, coming 
      out, transitioning, and coping with discrimination or stigma. It is 
      important to note that therapy sessions are confidential and the 
      therapist will work with the individual to create a safe and supportive 
      environment for exploring their gender identity.
    END_OF_COMMENT
      .tr("\n"," ").squeeze(" ").strip.gsub("<p>", "\n")

    add_column :account_holders, :gender_identity, :string, null: false, default: "", if_not_exists: true,
      comment: <<~END_OF_COMMENT
        Gender Identity is Protected Health Information (PHI) according to
        Health Insurance Portability and Accountability Act of 1996 (HIPAA) 
        Privacy Rules. Specifically, HIPAA prohibits the disclosure of 
        protected health information about gender-affirming care without 
        consent except in limited circumstances. One of these limited 
        circumstances—where disclosure may be possible without a patient's 
        consent—is when disclosure is required under another law.
        <p><p>
        In therapy sessions, the term "gender identity" is commonly used to 
        refer to an individual's internal sense of their own gender, which 
        may or may not align with the sex they were assigned at birth. 
        Therapists may work with individuals to explore and understand 
        their gender identity, and to help them navigate any challenges or 
        difficulties they may face as a result of their gender identity. 
        This may involve discussing issues such as gender dysphoria, coming 
        out, transitioning, and coping with discrimination or stigma. It is 
        important to note that therapy sessions are confidential and the 
        therapist will work with the individual to create a safe and supportive 
        environment for exploring their gender identity.
      END_OF_COMMENT
        .tr("\n"," ").squeeze(" ").strip.gsub("<p>", "\n")

    drop_table :gender_identities if table_exists?(:gender_identities)

    create_table :gender_identities, 
        comment: <<~END_OF_COMMENT
          Gender Identity (GI) is how the patient views their own gender.  This 
          may or may not be the same as the gender to which they were born.  The
          table is a mapping (cross-reference) of the GI used within the ABIE/OBIE 
          applications with the GI that is used within the AMD 3rd party electronic 
          health records (EHR) product.
        END_OF_COMMENT
          .tr("\n"," ").squeeze(" ").strip.gsub("<p>", "\n") do |t|

      t.string  :gi,            null: false, default: '', 
        comment: "Gender Identity used within ABIE/OBIE"

      t.integer :amd_gi_ident,  null: false, default: 0,
        comment:  "This is the way that AMD identifies this GI in it's database. " \
                  "It is also the value that AMD expects in it's patient API."

      t.string  :amd_gi,        null: false, default: '',
        comment: "Gender Identity used within AMD"

      t.timestamps
    end

    add_index :gender_identities, :gi,            unique: true
    add_index :gender_identities, :amd_gi,        unique: true
    add_index :gender_identities, :amd_gi_ident,  unique: true
  end
end
