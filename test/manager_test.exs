defmodule ManagerTest do
  use ExUnit.Case

  setup do
    Application.put_env(:crawly, :concurrent_requests_per_domain, 1)
    Application.put_env(:crawly, :closespider_itemcount, 10)

    :meck.expect(HTTPoison, :get, fn _, _, _ ->
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body: "Some page",
         headers: [],
         request: %{}
       }}
    end)

    on_exit(fn ->
      :meck.unload(HTTPoison)
      Application.put_env(:crawly, :manager_operations_timeout, 30_000)
      Application.put_env(:crawly, :concurrent_requests_per_domain, 1)
      Application.put_env(:crawly, :closespider_timeout, 20)
      Application.put_env(:crawly, :closespider_itemcount, 100)
    end)
  end

  test "test normal spider behavior" do
    :ok = Crawly.Engine.start_spider(Manager.TestSpider)

    {:stored_requests, num} = Crawly.RequestsStorage.stats(Manager.TestSpider)
    assert num == 1
    Process.sleep(5_00)

    {:stored_items, num} = Crawly.DataStorage.stats(Manager.TestSpider)
    assert num == 1

    :ok = Crawly.Engine.stop_spider(Manager.TestSpider)
    assert %{} == Crawly.Engine.running_spiders()
  end

  test "Closespider itemcount is respected" do
    Application.put_env(:crawly, :manager_operations_timeout, 1_000)
    Application.put_env(:crawly, :closespider_timeout, 1)
    Application.put_env(:crawly, :concurrent_requests_per_domain, 5)
    Application.put_env(:crawly, :closespider_itemcount, 3)
    :ok = Crawly.Engine.start_spider(Manager.TestSpider)

    Process.sleep(2_000)
    assert %{} == Crawly.Engine.running_spiders()
  end

  test "Closespider timeout is respected" do
    Application.put_env(:crawly, :manager_operations_timeout, 1_000)
    Application.put_env(:crawly, :concurrent_requests_per_domain, 1)
    :ok = Crawly.Engine.start_spider(Manager.TestSpider)
    Process.sleep(2_000)
    stats = Crawly.DataStorage.stats(Manager.TestSpider)
    IO.puts("Stats: #{inspect(stats)}")
    assert %{} == Crawly.Engine.running_spiders()
  end

  test "Can't start already started spider" do
    :ok = Crawly.Engine.start_spider(Manager.TestSpider)
    assert {:error, :spider_already_started} == Crawly.Engine.start_spider(Manager.TestSpider)
    :ok = Crawly.Engine.stop_spider(Manager.TestSpider)
  end


  test "Can't stop the spider which is not started already started spider" do
    :ok = Crawly.Engine.start_spider(Manager.TestSpider)
    assert {:error, :spider_already_started} == Crawly.Engine.start_spider(Manager.TestSpider)
    :ok = Crawly.Engine.stop_spider(Manager.TestSpider)
  end
end

defmodule Manager.TestSpider do
  def base_url() do
    "https://www.example.com"
  end

  def init() do
    [
      start_urls: ["https://www.example.com/blog.html"]
    ]
  end

  def parse_item(_response) do
    path = Enum.random(1..100)
    %{
      :items => [
        %{title: "t_#{path}", url: "example.com", author: "Me", time: "not set"}
      ],
      :requests => [
        Crawly.Utils.request_from_url("https://www.example.com/#{path}")]
    }
  end
end
