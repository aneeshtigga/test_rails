require "rails_helper"

RSpec.describe "SSO Auth", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:stub_time) { Time.new(2021, 11, 10, 15, 44, 32) }

  before do
    travel_to stub_time
  end

  describe "POST /api/v1/auth" do
    describe "with a valid token" do
      params = {
        'jwt': "eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZDQkMtSFM1MTIifQ.k1QiZf1loM48Fs1BTy42KJSv2Rfu-p6OdjNBLR-dsHn4hbsc9v0Uji2PRTzEl9zDJPJzFkfA7dD0xj5rpCRPhdKotm_P5cNNx8bMWVBzaEESSLLQ-TPKDHMh4mZESSx9OxGck2kaTonpcdLMWbTaw7fhtFDTQk8wiflN3GqyHL90_-FG3uraQYvpgSH1iKtmM-IOpjYC2mfWMePCRT6KHbgfF_znqzgzKoVj0ScMWBelzYXHc6tEjY6bGh1tYK3rCGD0VjHUD6ttLNPrHdua3qSZC03dfU6ipAH8VWv1hrNlFe289RqsqMShhRpBLyvUsb1s_x57qp31BmadkNitYw.q0oM0lq9Qz8WAXvgMfA3vw.bRH-QDEd4ccgInW4KCl5gzi9DPjegrcZB54bnqGBJcOHCwF-1VwA3oBzeDr5CC1uKq9CRjO-DhQyj90qrC5KV0uiaunF0qPI6_js3wPfJyDqE0aP-AE-C8ABCYKa7kpDawqoDTRGxsJBV23pVDGUUGyt36hlNuhB0YpWleMdhmFsxPoX3TSUvJH0pwG9RscdlRc4S_urv9fMhea9oDOKhXPYWCIAhIFTR0KN1lGVYBD-yBUnJqZ3z4eZOzR_IjzeKE2YIHYthkgiHcTlFlpNrrL8lTCqVdGR9EfBhOW-IVhRQwB-cgXcq-LiMzhu7SeWOqwz0m4AyBeatMJwcI4e-PHlUKxZGM27u5nG0y0pxDBxAMfdududSGGQoLBkeC0hrp-6gEaXs5mA8UWoig3JlRvXpN5Beq3tefnQmDnDxar_xW8B-gH2XwZp20zDpWuzpfySdULkUSRKA7cFY_ln7jRiMMw8wa1Io75K0fsg3E2g51dxfcy6Sui4MIVd_JsyhVX2BLNfurY6Regur_3_f1VKdrhP5yoQ_cC3-E-87aYg59VjoeHWqSp9fsFQlGsDXNEUmaxlqaiFqIyL7rgZkI-xUIzRF0rx1lV_-a3KdujDGT8_KOEQHSCeMprP3iDf8sEZwRrftFKHgOffIIHqcvGXYqOGGq7792_LQudndOf_F9gg7Bfu1B8HVp7zuKJk1nfLGhEQWJBHZ-SurLJtvm8QcxRiKcoOJlAyf7kFu0BzznX7mPUkU9iK3CdwXrW1PsNBf1-LaAqG39aF7ZPBsYwM9Gprbc7Ka0djuA-N7KN1-_ZypOKxYzE0q5OkUXIsJ48TQd2u_JxABaiNNfYZE051BwGlxlgr3kQdyxB1iMsxQqxhly6WjIY0U9piompA-0tKX8TKeorzDb3ZxPyOJTDPj08whFMq6EctQNM4dsTDsZCygGjqR8rg4S2CdQgrYGjuD3dtNuCHZlTUyw-1dd8W_Ry0ruCkw7jnkd3cVtfehdTtWwoo2STQiBY0ny8Crkv2b0wg_hdW9V5mLx53UjpPEXUxQhpUATljBw2OPdMbX2zgFm4lD2V8UEbajMGvWCBOdD_qzsHcQ7mM1aos03H6S2i41liuPFY1s1-gwVXhkqWRV0FdJGibpzNk38ORsYWlfgIhlCMo_vrxirvmElGkbkoOLlFTmI2iT0r5-wCeO3e4omru4mHFB8NybVU1Y74iuwKtj9Sizn5qcr7XXnYVDq9CA6J-w5AFSfd-UUIg3vNG6gaek9tryJwUktvE962OSRcHXoBHQkeKh-kRrh3w06U9tR6ZcTedemJxOA0u8oHD0Waseyvn3oGFvO2mMKMpokGsCGDpY7uHO8RNi5Z8MR0m27C9uMSvbuIVMBsIOAEvIZGYOv7S8GMj4Wl24c9L9QuVR_WwNbKsIV6ykP-y2OHyRLKC5xPmD1B7UJLjPqY9Xcs64_D68gUoqcxY4ja56sJqjp075IUusZ3Ay2TSuXkD8QV5ZehBJUdpZ5M.Wms63L8fhpXDnctMSoUg8Rz2_aTeBr9QJ8SBZqjf1hA"
      }

      it "creates an sso token" do
        post "/api/v1/auth", params: params

        expect(SsoToken.count).to eq(1)
      end

      # TODO: Update cert to reflect new domain name
      pending "returns success" do
        post "/api/v1/auth", params: params
        token = SsoToken.last.token
        expect(response).to have_http_status(:success)
        expect(json_response["redirect_url"]).to eq("https://dev-book.lifestance.com/find-care/booking/followup?token=#{token}")
        pending
      end
    end

    describe "token is invalid" do
      it "returns unprocessable entity" do
        post "/api/v1/auth", params: { "jwt" => "1234.543.123" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "token couldn't be decrypted" do
      it "returns unprocessable entity" do
        unprocessed_token_params = {
          'jwt': "1111111111JSU0ExXzUiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0.DQhzVL3CfqGYax1EYEy_YWDaJnrvfOGjpryfqeWv7RhNUt7RswagHr9UAX2pALDpxPD7swyblbZ-J7BRLfIy0Jh_L8cBHt1aQjpQwy7cysddvdg1Zvj0RrKU508n8s_bi-usPtYY9bi-Jf4s8DFffvPgxBPYG9_3_vXcO2hGPAC_aFY0cQoVSyPjXeptTvdoVbpLYJFz5qBD_mLAVgR0eNqn2ngB7Y9GDU0FEHhQaCsdErE9bQfE2o6VZ0lwOEMwl2D2IaI9A1VHQICNx99SByelgpsj2Tx1Rf1yRNMZ2LnGFDpB69vphBm20zbALj0_Xt2yCH-CYpbK5tQb-_XM_g.Akyh6rYRPS8Vm7nnPhgNNQ.iOEc-VALDZlaWe7T9hWbEuY3UB99DE2WgxD2C5xI2ZF6F4cz-JfHZJb8aXAuYBEJnBDIRZZeIT0Kp0DFcesDSd-RyN1cr50-rk7HYdR_xuy7kwmvknozqlciNacHPzcX3iC26be40so4yVZKp7YS0HEb3B1PBSgBxuPBiZD-7OzWVZph-YbtZQja8eWWYtSHKDk2rzst7-onOzgC4GeX-bR7DJynZWPV7CMEXpJ80BSJZdkU8kX4XwWpR0PWUVlP5iVpinCD42QEB30U1VPeCgSUXEUFI1L9cmdr2oJc5NOWrhfxHAmi6F_Uk8wG0CeU0ylGiZhH9g1zerJZzHI8ECYW2Lv_lJjHpIeSyKBxIp_lIyTokxa8QnmD69kBhXoc2k-UaOzaNi4vovIQ7AabVs86hpaqYdWSqogd6Sjr3kR98AMwLTbDMBpcrPMY8PrL2_SyTCVvr6cN6L56RT3Ncvhd4ecC7aheydkca1RyZw8tbuvEMNinz1UnC6fjUMgSsWdMQcXcOgJ42jarQseQevqaNvQfyGB92rY28xT85FY.I8PsHJsXGp5ems1yhb5kLQ"
        }
        post "/api/v1/auth", params: unprocessed_token_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "Missing required params" do
      it "returns unprocessable entity" do
        post "/api/v1/auth"

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /api/v1/auth" do
    let!(:stub_time) { Time.new(2021, 11, 10, 15, 44, 32) }
    params = {
      'jwt': "eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZDQkMtSFM1MTIifQ.k1QiZf1loM48Fs1BTy42KJSv2Rfu-p6OdjNBLR-dsHn4hbsc9v0Uji2PRTzEl9zDJPJzFkfA7dD0xj5rpCRPhdKotm_P5cNNx8bMWVBzaEESSLLQ-TPKDHMh4mZESSx9OxGck2kaTonpcdLMWbTaw7fhtFDTQk8wiflN3GqyHL90_-FG3uraQYvpgSH1iKtmM-IOpjYC2mfWMePCRT6KHbgfF_znqzgzKoVj0ScMWBelzYXHc6tEjY6bGh1tYK3rCGD0VjHUD6ttLNPrHdua3qSZC03dfU6ipAH8VWv1hrNlFe289RqsqMShhRpBLyvUsb1s_x57qp31BmadkNitYw.q0oM0lq9Qz8WAXvgMfA3vw.bRH-QDEd4ccgInW4KCl5gzi9DPjegrcZB54bnqGBJcOHCwF-1VwA3oBzeDr5CC1uKq9CRjO-DhQyj90qrC5KV0uiaunF0qPI6_js3wPfJyDqE0aP-AE-C8ABCYKa7kpDawqoDTRGxsJBV23pVDGUUGyt36hlNuhB0YpWleMdhmFsxPoX3TSUvJH0pwG9RscdlRc4S_urv9fMhea9oDOKhXPYWCIAhIFTR0KN1lGVYBD-yBUnJqZ3z4eZOzR_IjzeKE2YIHYthkgiHcTlFlpNrrL8lTCqVdGR9EfBhOW-IVhRQwB-cgXcq-LiMzhu7SeWOqwz0m4AyBeatMJwcI4e-PHlUKxZGM27u5nG0y0pxDBxAMfdududSGGQoLBkeC0hrp-6gEaXs5mA8UWoig3JlRvXpN5Beq3tefnQmDnDxar_xW8B-gH2XwZp20zDpWuzpfySdULkUSRKA7cFY_ln7jRiMMw8wa1Io75K0fsg3E2g51dxfcy6Sui4MIVd_JsyhVX2BLNfurY6Regur_3_f1VKdrhP5yoQ_cC3-E-87aYg59VjoeHWqSp9fsFQlGsDXNEUmaxlqaiFqIyL7rgZkI-xUIzRF0rx1lV_-a3KdujDGT8_KOEQHSCeMprP3iDf8sEZwRrftFKHgOffIIHqcvGXYqOGGq7792_LQudndOf_F9gg7Bfu1B8HVp7zuKJk1nfLGhEQWJBHZ-SurLJtvm8QcxRiKcoOJlAyf7kFu0BzznX7mPUkU9iK3CdwXrW1PsNBf1-LaAqG39aF7ZPBsYwM9Gprbc7Ka0djuA-N7KN1-_ZypOKxYzE0q5OkUXIsJ48TQd2u_JxABaiNNfYZE051BwGlxlgr3kQdyxB1iMsxQqxhly6WjIY0U9piompA-0tKX8TKeorzDb3ZxPyOJTDPj08whFMq6EctQNM4dsTDsZCygGjqR8rg4S2CdQgrYGjuD3dtNuCHZlTUyw-1dd8W_Ry0ruCkw7jnkd3cVtfehdTtWwoo2STQiBY0ny8Crkv2b0wg_hdW9V5mLx53UjpPEXUxQhpUATljBw2OPdMbX2zgFm4lD2V8UEbajMGvWCBOdD_qzsHcQ7mM1aos03H6S2i41liuPFY1s1-gwVXhkqWRV0FdJGibpzNk38ORsYWlfgIhlCMo_vrxirvmElGkbkoOLlFTmI2iT0r5-wCeO3e4omru4mHFB8NybVU1Y74iuwKtj9Sizn5qcr7XXnYVDq9CA6J-w5AFSfd-UUIg3vNG6gaek9tryJwUktvE962OSRcHXoBHQkeKh-kRrh3w06U9tR6ZcTedemJxOA0u8oHD0Waseyvn3oGFvO2mMKMpokGsCGDpY7uHO8RNi5Z8MR0m27C9uMSvbuIVMBsIOAEvIZGYOv7S8GMj4Wl24c9L9QuVR_WwNbKsIV6ykP-y2OHyRLKC5xPmD1B7UJLjPqY9Xcs64_D68gUoqcxY4ja56sJqjp075IUusZ3Ay2TSuXkD8QV5ZehBJUdpZ5M.Wms63L8fhpXDnctMSoUg8Rz2_aTeBr9QJ8SBZqjf1hA"
    }

    before do
      allow(Rails.application.credentials).to receive(:sso_debug).and_return(nil)
    end

    describe "Token expiration" do
      context "current time is equal to token issued at" do
        it "return token expiration error" do
          travel_to stub_time
          post "/api/v1/auth", params: params
          
          expect(response.status).to eq(422)
          # expect(response).not_to have_http_status(:unprocessable_entity)

          travel_back
        end
      end

      # context "current time is equal to 1 minute after issued at" do
      #   it "return token expiration error" do
      #     travel_to (stub_time + 1.minute)
      #     post "/api/v1/auth", params: params
      #     expect(response).to have_http_status(:unprocessable_entity)
      #     expect(json_response["message"]).to eq("Expired token")
      #     travel_back
      #   end
      # end

      # context "current time is after 1 minute after issued at" do
      #   it "return token expiration error" do
      #     travel_to (stub_time + 1.5.minute)
      #     post "/api/v1/auth", params: params
      #     expect(response).to have_http_status(:unprocessable_entity)
      #     expect(json_response["message"]).to eq("Expired token")
      #     travel_back
      #   end
      # end
    end
  end

  describe "SSO debugging is enabled" do
    before(:each) do
      allow(Rails.application.credentials).to receive(:sso_debug).and_return(true)
    end

    params = {
      'jwt': "eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZDQkMtSFM1MTIifQ.k1QiZf1loM48Fs1BTy42KJSv2Rfu-p6OdjNBLR-dsHn4hbsc9v0Uji2PRTzEl9zDJPJzFkfA7dD0xj5rpCRPhdKotm_P5cNNx8bMWVBzaEESSLLQ-TPKDHMh4mZESSx9OxGck2kaTonpcdLMWbTaw7fhtFDTQk8wiflN3GqyHL90_-FG3uraQYvpgSH1iKtmM-IOpjYC2mfWMePCRT6KHbgfF_znqzgzKoVj0ScMWBelzYXHc6tEjY6bGh1tYK3rCGD0VjHUD6ttLNPrHdua3qSZC03dfU6ipAH8VWv1hrNlFe289RqsqMShhRpBLyvUsb1s_x57qp31BmadkNitYw.q0oM0lq9Qz8WAXvgMfA3vw.bRH-QDEd4ccgInW4KCl5gzi9DPjegrcZB54bnqGBJcOHCwF-1VwA3oBzeDr5CC1uKq9CRjO-DhQyj90qrC5KV0uiaunF0qPI6_js3wPfJyDqE0aP-AE-C8ABCYKa7kpDawqoDTRGxsJBV23pVDGUUGyt36hlNuhB0YpWleMdhmFsxPoX3TSUvJH0pwG9RscdlRc4S_urv9fMhea9oDOKhXPYWCIAhIFTR0KN1lGVYBD-yBUnJqZ3z4eZOzR_IjzeKE2YIHYthkgiHcTlFlpNrrL8lTCqVdGR9EfBhOW-IVhRQwB-cgXcq-LiMzhu7SeWOqwz0m4AyBeatMJwcI4e-PHlUKxZGM27u5nG0y0pxDBxAMfdududSGGQoLBkeC0hrp-6gEaXs5mA8UWoig3JlRvXpN5Beq3tefnQmDnDxar_xW8B-gH2XwZp20zDpWuzpfySdULkUSRKA7cFY_ln7jRiMMw8wa1Io75K0fsg3E2g51dxfcy6Sui4MIVd_JsyhVX2BLNfurY6Regur_3_f1VKdrhP5yoQ_cC3-E-87aYg59VjoeHWqSp9fsFQlGsDXNEUmaxlqaiFqIyL7rgZkI-xUIzRF0rx1lV_-a3KdujDGT8_KOEQHSCeMprP3iDf8sEZwRrftFKHgOffIIHqcvGXYqOGGq7792_LQudndOf_F9gg7Bfu1B8HVp7zuKJk1nfLGhEQWJBHZ-SurLJtvm8QcxRiKcoOJlAyf7kFu0BzznX7mPUkU9iK3CdwXrW1PsNBf1-LaAqG39aF7ZPBsYwM9Gprbc7Ka0djuA-N7KN1-_ZypOKxYzE0q5OkUXIsJ48TQd2u_JxABaiNNfYZE051BwGlxlgr3kQdyxB1iMsxQqxhly6WjIY0U9piompA-0tKX8TKeorzDb3ZxPyOJTDPj08whFMq6EctQNM4dsTDsZCygGjqR8rg4S2CdQgrYGjuD3dtNuCHZlTUyw-1dd8W_Ry0ruCkw7jnkd3cVtfehdTtWwoo2STQiBY0ny8Crkv2b0wg_hdW9V5mLx53UjpPEXUxQhpUATljBw2OPdMbX2zgFm4lD2V8UEbajMGvWCBOdD_qzsHcQ7mM1aos03H6S2i41liuPFY1s1-gwVXhkqWRV0FdJGibpzNk38ORsYWlfgIhlCMo_vrxirvmElGkbkoOLlFTmI2iT0r5-wCeO3e4omru4mHFB8NybVU1Y74iuwKtj9Sizn5qcr7XXnYVDq9CA6J-w5AFSfd-UUIg3vNG6gaek9tryJwUktvE962OSRcHXoBHQkeKh-kRrh3w06U9tR6ZcTedemJxOA0u8oHD0Waseyvn3oGFvO2mMKMpokGsCGDpY7uHO8RNi5Z8MR0m27C9uMSvbuIVMBsIOAEvIZGYOv7S8GMj4Wl24c9L9QuVR_WwNbKsIV6ykP-y2OHyRLKC5xPmD1B7UJLjPqY9Xcs64_D68gUoqcxY4ja56sJqjp075IUusZ3Ay2TSuXkD8QV5ZehBJUdpZ5M.Wms63L8fhpXDnctMSoUg8Rz2_aTeBr9QJ8SBZqjf1hA"
    }

    # TODO: Update cert to reflect new domain name
    pending "skips verifying the issued at date" do
      post "/api/v1/auth", params: params
      token = SsoToken.last.token
      expect(response).to have_http_status(:success)
      expect(json_response["redirect_url"]).to eq("https://dev-book.lifestance.com/find-care/booking/followup?token=#{token}")
    end
  end

  describe "Delete /api/v1/logout" do
    describe "with valid token" do
      params = {
        'jwt': "eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZDQkMtSFM1MTIifQ.k1QiZf1loM48Fs1BTy42KJSv2Rfu-p6OdjNBLR-dsHn4hbsc9v0Uji2PRTzEl9zDJPJzFkfA7dD0xj5rpCRPhdKotm_P5cNNx8bMWVBzaEESSLLQ-TPKDHMh4mZESSx9OxGck2kaTonpcdLMWbTaw7fhtFDTQk8wiflN3GqyHL90_-FG3uraQYvpgSH1iKtmM-IOpjYC2mfWMePCRT6KHbgfF_znqzgzKoVj0ScMWBelzYXHc6tEjY6bGh1tYK3rCGD0VjHUD6ttLNPrHdua3qSZC03dfU6ipAH8VWv1hrNlFe289RqsqMShhRpBLyvUsb1s_x57qp31BmadkNitYw.q0oM0lq9Qz8WAXvgMfA3vw.bRH-QDEd4ccgInW4KCl5gzi9DPjegrcZB54bnqGBJcOHCwF-1VwA3oBzeDr5CC1uKq9CRjO-DhQyj90qrC5KV0uiaunF0qPI6_js3wPfJyDqE0aP-AE-C8ABCYKa7kpDawqoDTRGxsJBV23pVDGUUGyt36hlNuhB0YpWleMdhmFsxPoX3TSUvJH0pwG9RscdlRc4S_urv9fMhea9oDOKhXPYWCIAhIFTR0KN1lGVYBD-yBUnJqZ3z4eZOzR_IjzeKE2YIHYthkgiHcTlFlpNrrL8lTCqVdGR9EfBhOW-IVhRQwB-cgXcq-LiMzhu7SeWOqwz0m4AyBeatMJwcI4e-PHlUKxZGM27u5nG0y0pxDBxAMfdududSGGQoLBkeC0hrp-6gEaXs5mA8UWoig3JlRvXpN5Beq3tefnQmDnDxar_xW8B-gH2XwZp20zDpWuzpfySdULkUSRKA7cFY_ln7jRiMMw8wa1Io75K0fsg3E2g51dxfcy6Sui4MIVd_JsyhVX2BLNfurY6Regur_3_f1VKdrhP5yoQ_cC3-E-87aYg59VjoeHWqSp9fsFQlGsDXNEUmaxlqaiFqIyL7rgZkI-xUIzRF0rx1lV_-a3KdujDGT8_KOEQHSCeMprP3iDf8sEZwRrftFKHgOffIIHqcvGXYqOGGq7792_LQudndOf_F9gg7Bfu1B8HVp7zuKJk1nfLGhEQWJBHZ-SurLJtvm8QcxRiKcoOJlAyf7kFu0BzznX7mPUkU9iK3CdwXrW1PsNBf1-LaAqG39aF7ZPBsYwM9Gprbc7Ka0djuA-N7KN1-_ZypOKxYzE0q5OkUXIsJ48TQd2u_JxABaiNNfYZE051BwGlxlgr3kQdyxB1iMsxQqxhly6WjIY0U9piompA-0tKX8TKeorzDb3ZxPyOJTDPj08whFMq6EctQNM4dsTDsZCygGjqR8rg4S2CdQgrYGjuD3dtNuCHZlTUyw-1dd8W_Ry0ruCkw7jnkd3cVtfehdTtWwoo2STQiBY0ny8Crkv2b0wg_hdW9V5mLx53UjpPEXUxQhpUATljBw2OPdMbX2zgFm4lD2V8UEbajMGvWCBOdD_qzsHcQ7mM1aos03H6S2i41liuPFY1s1-gwVXhkqWRV0FdJGibpzNk38ORsYWlfgIhlCMo_vrxirvmElGkbkoOLlFTmI2iT0r5-wCeO3e4omru4mHFB8NybVU1Y74iuwKtj9Sizn5qcr7XXnYVDq9CA6J-w5AFSfd-UUIg3vNG6gaek9tryJwUktvE962OSRcHXoBHQkeKh-kRrh3w06U9tR6ZcTedemJxOA0u8oHD0Waseyvn3oGFvO2mMKMpokGsCGDpY7uHO8RNi5Z8MR0m27C9uMSvbuIVMBsIOAEvIZGYOv7S8GMj4Wl24c9L9QuVR_WwNbKsIV6ykP-y2OHyRLKC5xPmD1B7UJLjPqY9Xcs64_D68gUoqcxY4ja56sJqjp075IUusZ3Ay2TSuXkD8QV5ZehBJUdpZ5M.Wms63L8fhpXDnctMSoUg8Rz2_aTeBr9QJ8SBZqjf1hA"
      }

      it "deletes the session" do
        post "/api/v1/auth", params: params

        expect(SsoToken.count).to eq(1)
        token = create(:sso_token, token: "12345", data: { selected_patient_id: "100" })
        get "/api/v1/patient_info", params: { token: "12345" }

        session_id = response.cookies["_lfst_session"]
        request.cookies["_lfst_session"] = session_id
        delete "/api/v1/logout"

        expect(response).to have_http_status(:no_content)

        get "/api/v1/patient_info"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
