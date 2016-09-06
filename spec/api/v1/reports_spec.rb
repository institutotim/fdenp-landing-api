require 'spec_helper'

describe API::V1::Reports do
  describe 'POST /reports', :vcr do
    context 'success' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "user_id": "1",
            "reportee_name": "Juliano Meyra",
            "address": "R. Humberto Luís Gastaldo",
            "number": "10",
            "district": "Jardim do Mar"
          }
        JSON
      end

      def make_post_request
        post '/v1/reports', valid_params
      end

      it 'returns a 201 success status' do
        make_post_request
        expect(response.status).to eq(201)
      end

      it 'returns a success message' do
        make_post_request
        body = parsed_body
        expect(body['message']).to eq('Relato criado com sucesso')
      end

      it 'calls zup-api with the correct user params to get user info' do
        expect(RestClient).to receive(:get).with('http://localhost:3000/users/1', kind_of(Hash)).and_call_original

        make_post_request
      end

      it 'calls zup-api with the correct report params to create the report' do
        report_params = {
          user_id: 1,
          reportee_name: 'Juliano Meyra',
          address: 'R. Humberto Luís Gastaldo',
          number: '10',
          district: 'Jardim do Mar',
          description: 'Enviado pelo formulário online do Criança Fora da Escola Não Pode!',
          latitude: -23.6781693,
          longitude: -46.5578292
        }

        expect(RestClient).to receive(:post).once.with('http://localhost:3000/reports/2/items', report_params.to_json, kind_of(Hash)).and_call_original
        expect(RestClient).to receive(:post).once.with(any_args).and_call_original

        make_post_request
      end

      it 'calls zup-api with the correct case params to create the case' do
        case_fields = []
        case_fields << { id: ENV['ZUP_API_CHILD_NAME_FIELD_ID'], value: 'Juliano Meyra' }
        case_fields << { id: ENV['ZUP_API_CHILD_MOTHER_NAME_FIELD_ID'], value: nil }
        case_fields << { id: ENV['ZUP_API_CHILD_BIRTHDAY_FIELD_ID'], value: nil }

        case_params = {
          initial_flow_id: ENV['ZUP_API_FLOW_ID'],
          fields: case_fields,
          responsible_user_id: 1
        }

        expect(RestClient).to receive(:post).once.with(any_args).and_call_original
        expect(RestClient).to receive(:post).once.with("#{ENV['ZUP_API_URL']}/cases", case_params.to_json, kind_of(Hash)).and_call_original

        make_post_request
      end
    end

    context 'invalid params' do
      let(:invalid_params) do
        Oj.load <<-JSON
          {
            "reportee_name": "Juliano Meyra"
          }
        JSON
      end

      it 'returns a 422 error status' do
        post '/v1/reports', invalid_params
        expect(response.status).to eq(422)
      end
    end

    context 'not authenticated on zup-unicef-api'

    context 'wrong token with ZUP API'

    context 'ZUP API couldnt create the report'
  end
end
