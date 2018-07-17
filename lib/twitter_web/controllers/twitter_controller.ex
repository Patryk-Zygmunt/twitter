defmodule TwitterWeb.TwitterController do
  use TwitterWeb, :controller
  
  def followers(conn, _params) do
      user_id = get_session(conn,:user_id)
      {:ok, {{_, _, _}, _headers, body}} =
      :httpc.request(:get, {to_charlist("http://localhost:8080/following/" <> user_id), []}, [], [])
      decoded =  Poison.decode!(body)
      f = Enum.to_list(Stream.map(decoded, &create_user/1))
    render conn, "followers.html" ,foll: f
  end
  
    def discover(conn, _params) do
      {:ok, {{_, _, _}, _headers, body}} =
      :httpc.request(:get, {to_charlist("http://localhost:8080/all"), []}, [], [])
      user_id = get_session(conn,:user_id)
      {:ok, {{_, _, _}, _fheaders, fbody}} =
      :httpc.request(:get, {to_charlist("http://localhost:8080/following/" <> user_id), []}, [], [])
      decoded =  Poison.decode!(body)
      following =  Poison.decode!(fbody)
      f = Enum.to_list(Stream.map(decoded,fn all-> {isFollowed(all,following),(create_user all)} end ))
      IO.inspect f
    render conn, "discover.html" ,foll: f
  end
  
  
 def tweets(conn, param) do
      id = get_session(conn,:user_id)
      {:ok, {{_, _, _}, _headers, body}} =
      :httpc.request(:get, {to_charlist("http://localhost:8080/tweets/" <> id), []}, [], [])
      decoded =  Poison.decode!(body)
      tw = Enum.to_list(Stream.map(decoded,fn t-> {(create_user (Map.get(t,"user"))),(create_tweet (Map.get(t,"tweet")))} end))
    conn
    |>put_flash(:info, "#{length decoded} new tweets")
    |>assign(:tweets, tw)
    |>render("twitter.html")
 end
  
 
 def new_tweet(conn,param) do
    IO.inspect param
    body = Poison.encode!(%{:text => Map.get(param,"text")})
    user_id = get_session(conn,:user_id)
   {_status, {{_, _, _}, _headers, _body}} =
      :httpc.request(:post, {to_charlist("http://localhost:8080/tweet/" <> user_id), [],'application/json', body}, [], [])
    redirect conn, to: "/tweets"
  end
 
  
  def follow(conn,param) do
    user_id = get_session(conn,:user_id)
   {_status, {{_, _, _}, _headers, _body}} =
      :httpc.request(:put, {to_charlist("http://localhost:8080/follow/" <> user_id <> "?follow=" <> Map.get(param,"follow_id")), [] ,'application/json', ""}, [], [])
    redirect conn, to: "/discover" 
  end
 
  def unfollow(conn,param) do
    IO.inspect conn.path_info 
    user_id = get_session(conn,:user_id)
   {_status, {{_, _, _}, _headers, _body}} =
      :httpc.request(:delete, {to_charlist("http://localhost:8080/follow/" <> user_id <> "?unfollow=" <> Map.get(param,"follow_id")), [] ,'application/json', ""}, [], [])
    redirect conn, to: "/discover" 
  end

 def login(conn, param) do
    IO.inspect param 
   {_status, {{_, _, _}, _headers, id}} =
      :httpc.request(:get, {to_charlist("http://localhost:8080/login/" <> Map.get(param,"login")), []}, [], [])
      conn = put_session(conn, :user_id, to_string id)
      conn = put_session(conn, :user_name, to_string Map.get(param,"login"))
    redirect conn, to: "/tweets" 
  end

  
  
  
  
  def isFollowed(u,followed) do
         length(Enum.to_list(Stream.filter(followed,fn f->Map.get(f,"id") == Map.get(u,"id")  end))) >0 
  end
 
  def create_user(map) do
       %User{name: Map.get(map,"name"),age: Map.get(map,"age"),id: Map.get(map,"id")}
  end
  
  def create_tweet(map) do
        %Tweet{text: Map.get(map,"text"),date: Map.get(map,"date")}
  end
  
  
end
