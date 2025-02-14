require "rails_helper"

describe PostalCodeBuilder, type: :class do
  let!(:postal_code) { create(:postal_code) }
  subject { described_class.build(test_zip_code) } 
  describe 'self.build(zip_codes_array)' do
    context 'with a valid input' do
        context 'with a string input' do
            context 'with an existing zip code' do
                       
                let(:test_zip_code) { '99950' }
                
                it 'returns a valid PostalCode object' do
                expect(subject.zip_code).to eq test_zip_code
                end
            end
        end

        context 'with an integer input' do
          context 'with an existing zip code' do
              let(:test_zip_code) { 99950 }
      
              it 'returns a valid PostalCode object' do
                expect(subject.zip_code).to eq test_zip_code.to_s
              end
          end
        end

        context 'with an array of integers input' do
            context 'with an existing zip code' do
                let(:test_zip_code) { [99950, 12345] }
        
                it 'returns a valid PostalCode object' do
                  expect(subject.zip_code).to eq test_zip_code.first.to_s
                end
            end
        end
        
        context 'with an array of strings input' do
          context 'with an existing zip code' do
              let(:test_zip_code) { ['99950', '12345'] }
      
              it 'returns a valid PostalCode object' do
                expect(subject.zip_code).to eq test_zip_code.first.to_s
              end
          end
        end

        context 'with an array of mixed input' do
            context 'with an existing zip code' do
                let(:test_zip_code) { [99950, '12345'] }
        
                it 'returns a valid PostalCode object' do
                  expect(subject.zip_code).to eq test_zip_code.first.to_s
                end
            end
        end
    end

    context 'with invalid input' do
        context 'with an non-existant zip code' do
            let(:test_zip_code) { '12345' }
            
            it 'returns nil' do
              expect(subject).to be_nil
            end
        end

        context 'with a nonsense string' do
            let(:test_zip_code) { 'cookie monster' }
            
            it 'returns nil' do
              expect(subject).to be_nil
            end
        end

        context 'with a negative integer' do
            let(:test_zip_code) { -1 }
            
            it 'returns nil' do
              expect(subject).to be_nil
            end
        end

        context 'with a boolean' do
            let(:test_zip_code) { true }
            
            it 'returns nil' do
              expect(subject).to be_nil
            end
        end
    end
  end
end
