# Configure session store for better persistence
Rails.application.config.session_store :cookie_store,
                                       key: '_build_blog_session',
                                       expire_after: 2.weeks,
                                       secure: Rails.env.production?,
                                       httponly: true,
                                       same_site: :lax
