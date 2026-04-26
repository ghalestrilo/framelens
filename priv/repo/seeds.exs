# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Framelens.Repo.insert!(%Framelens.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# url not necessary
alias Framelens.Repo
alias Framelens.Creators.{Creator, CreatorPlatform}
alias Framelens.Subscriptions.Follow
alias Framelens.Accounts


multichannel_accounts = [
  %{
    name: "Zheanna Erose",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "digital.harmonic"
      },
      %{
        platform: "twitter",
        platform_id: "iamzheanna"
      },
      %{
        platform: "youtube",
        platform_id: "UC--VosYH0BHISbb4SFO9rQA"
      }
    ]
  },
  %{
    name: "Olivia Jack",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "o_jack"
      },
      %{
        platform: "twitter",
        platform_id: "_ojack_"
      },
      %{
        platform: "youtube",
        platform_id: "UC-2LWDrIxHOd2mnt1RHbzrg"
      }
    ]
  },
  %{
    name: "Ben Awad",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "benawad97"
      },
      %{
        platform: "twitter",
        platform_id: "benawad"
      },
      %{
        platform: "youtube",
        platform_id: "UC-8QAzbLcRglXeN_MY9blyw"
      }
    ]
  },
  %{
    name: "Not Just Bikes",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "notjustbikes"
      },
      %{
        platform: "twitter",
        platform_id: "notjustbikes"
      },
      %{
        platform: "youtube",
        platform_id: "UC0intLFzLaudFG-xAvUEO-A"
      }
    ]
  },
  %{
    name: "Philosophy Tube",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "philosophy.tube"
      },
      %{
        platform: "twitter",
        platform_id: "PhilosophyTube"
      },
      %{
        platform: "tiktok",
        platform_id: "theabigailthorn"
      },
      %{
        platform: "youtube",
        platform_id: "UC2PA-AKmVpU6NKCGtZq_rKQ"
      }
    ]
  },
  %{
    name: "Humberto Matos",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "prof_humberto_matos"
      },
      %{
        platform: "twitter",
        platform_id: "H1SaiaDaMatrix"
      },
      %{
        platform: "youtube",
        platform_id: "UC3qAUf53j_dUv09jH7jsUJw"
      }
    ]
  },
  %{
    name: "Cortes do Casimito [OFICIAL]",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "cortesdocasimiro"
      },
      %{
        platform: "twitter",
        platform_id: "cortesdocaze"
      },
      %{
        platform: "youtube",
        platform_id: "UC4aiJNDUviw_vMhdCq5Kq1Q"
      }
    ]
  },
  %{
    name: "Felipe Durante pelo mundo",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "felipe.durante"
      },
      %{
        platform: "twitter",
        platform_id: "fedurante"
      },
      %{
        platform: "youtube",
        platform_id: "UC53tme8fwwfiNs8WubMwC6g"
      }
    ]
  },
  %{
    name: "Wisecrack",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "wisecrack_official"
      },
      %{
        platform: "twitter",
        platform_id: "wisecrack"
      },
      %{
        platform: "youtube",
        platform_id: "UC6-ymYjG0SU0jUWnWh9ZzEQ"
      }
    ]
  },
  %{
    instagram_id: "assimdisseojoao",
    name: "João Carvalho",
    platforms: [
      %{
        platform: "twitter",
        platform_id: "assimdisseojoao"
      },
      %{
        platform: "tiktok",
        platform_id: "assimdisseojoao"
      },
      %{
        platform: "youtube",
        platform_id: "UC7-Pp09PJX_SYP9oyMzUAtg"
      }
    ]
  },
  %{
    name: "Programação Dinâmica",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "pgdinamica"
      },
      %{
        platform: "twitter",
        platform_id: "pgdinamica"
      },
      %{
        platform: "youtube",
        platform_id: "UC70mr11REaCqgKke7DPJoLg"
      }
    ]
  },
  %{
    name: "DankPods",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "podsdank"
      },
      %{
        platform: "twitter",
        platform_id: "PodsDank"
      },
      %{
        platform: "youtube",
        platform_id: "UC7Jwj9fkrf1adN4fMmTkpug"
      }
    ]
  },
  %{
    name: "Wendover Productions",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "wendoverproductions"
      },
      %{
        platform: "twitter",
        platform_id: "wendoverpro"
      },
      %{
        platform: "youtube",
        platform_id: "UC9RM-iSvTu1uPJb8X5yp3EQ"
      }
    ]
  },
  %{
    name: "Adam Ragusea",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "aragusea"
      },
      %{
        platform: "twitter",
        platform_id: "aragusea"
      },
      %{
        platform: "youtube",
        platform_id: "UC9_p50tH3WmMslWRWKnM7dQ"
      }
    ]
  },
  %{
    name: "Ian Neves",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "historiapublica_"
      },
      %{
        platform: "twitter",
        platform_id: "ianfneves"
      },
      %{
        platform: "youtube",
        platform_id: "UCAMExYqcweM7PUebKfmLdFA"
      }
    ]
  },
  %{
    name: "Tom Scott",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "tomscottgo"
      },
      %{
        platform: "twitter",
        platform_id: "tomscott"
      },
      %{
        platform: "youtube",
        platform_id: "UCBa659QWEk1AI4Tg--mrJ2A"
      }
    ]
  },
  %{
    name: "DESCE A LETRA SHOW",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "descealetrashow"
      },
      %{
        platform: "twitter",
        platform_id: "DesceALetraShow"
      },
      %{
        platform: "youtube",
        platform_id: "UCCD93px0UneWNFg_HxV4naQ"
      }
    ]
  },
  %{
    name: "Laurence Harrison",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "guitarlaurenceharrison"
      },
      %{
        platform: "youtube",
        platform_id: "UCDqaefcFrSnkKFZwIrKk4Fw"
      }
    ]
  },
  %{
    name: "Phillip McKnight",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "phillip_mcknight"
      },
      %{
        platform: "twitter",
        platform_id: "askknowyourgear"
      },
      %{
        platform: "youtube",
        platform_id: "UCEzJtFWNg7d7TZW7K9JyXmw"
      }
    ]
  },
  %{
    name: "Coffeezilla",
    platforms: [
      %{
        platform: "instagram",
        platform_id: "coffeebreak_yt"
      },
      %{
        platform: "twitter",
        platform_id: "coffeebreak_YT"
      },
      %{
        platform: "youtube",
        platform_id: "UCFQMnBA3CS502aghlcr0_aw"
      }
    ]
  }
]

test_user = Accounts.get_user_by_email("ghalestrilo@gmail.com")

if test_user do
  creator_ids =
    Enum.map(multichannel_accounts, fn %{platforms: platforms, name: name} ->
      creator =
        case Repo.get_by(Creator, name: name) do
          nil -> Repo.insert!(%Creator{name: name, platforms: platforms})
          existing -> existing
        end

      creator.id
    end)

  Enum.each(creator_ids, fn creator_id ->
    Repo.insert!(
      %Follow{user_id: test_user.id, creator_id: creator_id},
      on_conflict: :nothing,
      conflict_target: [:user_id, :creator_id]
    )
  end)

  IO.puts("Seeded #{length(creator_ids)} creators and follows for #{test_user.email}")
else
  IO.puts("User ghalestrilo@gmail.com not found — skipping creator/follow seed")
end
