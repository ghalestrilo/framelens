# Framelens

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix


<!-- Feature progress -->

Infinity scroll

- Added @page_size 20 module attribute.                                                                             
- Added all_posts and has_more assigns. all_posts holds the full sorted list from the cache but is never referenced 
in the template, so it's never serialized over the wire.                                                            
- paginate/2 helper slices all_posts by count and computes has_more.                                                
- New handle_event("load_more") takes the next @page_size elements from all_posts.                                  
- On :creator_fetched, the current visible count is preserved when new data arrives (so a user scrolled to row 60   
stays at 60+).                                                                                                      

- The container gets phx-hook=".InfiniteScroll".                                                                    
- A #scroll-sentinel div appears below the table only when @has_more is true — it disappears when the list is       
exhausted, disconnecting the observer automatically.                                                              
- A colocated <script> defines the InfiniteScroll hook using IntersectionObserver: when the sentinel scrolls into   
view it fires load_more, and updated() re-attaches the observer if the sentinel is recreated by LiveView patching.