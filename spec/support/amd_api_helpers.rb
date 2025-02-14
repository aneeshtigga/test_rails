module AmdApiHelpers
  def authenticate_amd_api
    session = create(:amd_api_session,
      office_code: 995456,
      token: "995456xMPCPJ8pT+FdHwviF9eS29kkCCeM9xUNnL9k81KTRAsHhRiSToheF8yCx9eueuf4fo/HRTFhi7O0yxwaH9CEKDMLyTbifSGgeDp6OciWzF8s4FlSoU5PZFrpS9FjzmBcoAhwZcR4mK+o/GlvrXcTswMds1KX/fzoUKOkqOvituiWqRI2d6TiUnI6G6mkhZgJCd3hYo8FYz7uGjel6fo6Og==",
      redirect_url: "https://provapi.advancedmd.com/processrequest/api-102/LIFESTANCE")

    allow(AmdApiSession).to receive(:create!).with(office_code: 995456).and_return(session)
  end

  def authenticate_amd(version)
    case version
    when 101
      Struct.new(:base_url, :token).new(
        "https://provapi.advancedmd.com/processrequest/api-101/LIFESTANCE",
        "995456JktmsPeCAFr5PNK1megpdZH5ANgXDKNWDK+d1jvWZyW3WWdQChhdBh3wq6immGVlM8Jj6bHvXXQYxlBqbhkp06F+QusKKuFKavl8P1/qib82J2gqQljBjwRaZuMwjEPSmO7MxX71nzGZIbDnKcWrsm9QDrdrsmeCi9M3tpgm/HsQzmBVStBAbmVylNwxSxLP2MUuo21zWSZulzUTyval3w=="
      )
    when 102
      Struct.new(:base_url, :token).new(
        "https://provapi.advancedmd.com/processrequest/api-102/LIFESTANCE",
        "995456AWX/4q//hQOSOP+0rsMonov4/bHaVJibxm3hyRv/qI7JpWUBjlTuVLlUGckePheIlklan3eaN1lnguYx+Nv8CKp0fYOuo72YYgQOuka2RYSO6fKJEfTgj5QqhASpozpKREN1ENkYkCMXHHs8nJ6w4oX60R+Dsa0ZEkS4IJCD8rUtUo18yWcEBF2nN51t+BIW1UYscsAG9BizZULhlhH+mQ=="
      )
    end
  end
end
