defmodule Framelens.Scraper do
  alias Framelens.Subscriptions

  @channels [
%{youtube_id: "UCuVuYmvwHJLtRfpXphPFm2w", name: "Felipe Durante"},
%{youtube_id: "UCsBjURrPoezykLs9EqgamOA", name: "Fireship"},
%{youtube_id: "UCrCTC5_t-HaVJ025DbYITiw", name: "Alice Cappelle"},
%{youtube_id: "UCqbz_4hrf2D58UFBOleuFnQ", name: "Gustavo Gaiofato | História Cabeluda"},
%{youtube_id: "UCq-V8B_t_gUWlAJ5YaJSRzQ", name: "revista piauí"},
%{youtube_id: "UCmopeXHb16dHZHI6qRWWkXg", name: "hate5six"},
%{youtube_id: "UCkIEY6rUSPy4qQjLqBBLUSg", name: "Via Infinda"},
%{youtube_id: "UCkmpC9Tqr1MUEcDK9Ie80Jw", name: "Mouts (Sua Mãe)"},
%{youtube_id: "UClGZuFQOesn7E2fvp8pm0kQ", name: "Estudio Laje"},
%{youtube_id: "UCiER8p540j2SosO7OX7E0VA", name: "Legends of Avantris"},
%{youtube_id: "UCiHJWmDw3tSgdqy_5OVOkGg", name: "Peter “Danish Pete” Honoré"},
%{youtube_id: "UCgi2u-lGY-2i2ubLsUr6FbQ", name: "F.D Signifier"},
%{youtube_id: "UCgvg86OqagNMJdCQne5adGg", name: "Canal Jota Dale"},
%{youtube_id: "UCcoxGCRGcq6FhHbEvr2y9Vg", name: "Ian Neves - História Pública"},
%{youtube_id: "UCbfYPyITQ-7l4upoX8nvctg", name: "Two Minute Papers"},
%{youtube_id: "UCbRP3c757lWg9M-U7TyEkXA", name: "Theo - t3․gg"},
%{youtube_id: "UCb3cDvWiHwRzQaK81PrISbg", name: "Leeja Miller"},
%{youtube_id: "UC_zQ777U6YTyatP3P1wi3xw", name: "NEVER TOO SMALL"},
%{youtube_id: "UCYVrkMZdrjq5eICOG6Rxiwg", name: "Tecnologia e Classe (TeClas)"},
%{youtube_id: "UCP9zziS-u29-MkghIFBU0ag", name: "UGREEN Educação "},
%{youtube_id: "UCMYA7_IJr3zkRk1AIp9JjaQ", name: "Hasanabi Better Clips"},
%{youtube_id: "UCK5DQ8FJWnI4DMtuoYtXEcg", name: "Mark Ericksen"},
%{youtube_id: "UCJHA_jMfCvEnv-3kRjTCQXw", name: "Binging with Babish"},
%{youtube_id: "UCEzJtFWNg7d7TZW7K9JyXmw", name: "Phillip McKnight"},
%{youtube_id: "UCDqaefcFrSnkKFZwIrKk4Fw", name: "Laurence Harrison"},
%{youtube_id: "UCBa659QWEk1AI4Tg--mrJ2A", name: "Tom Scott"},
%{youtube_id: "UCAMExYqcweM7PUebKfmLdFA", name: "Ian Neves"},
%{youtube_id: "UCCD93px0UneWNFg_HxV4naQ", name: "DESCE A LETRA SHOW"},
%{youtube_id: "UC7-Pp09PJX_SYP9oyMzUAtg", name: "João Carvalho"},
%{youtube_id: "UC6-ymYjG0SU0jUWnWh9ZzEQ", name: "Wisecrack"},
%{youtube_id: "UC53tme8fwwfiNs8WubMwC6g", name: "Felipe Durante pelo mundo"},
%{youtube_id: "UC3qAUf53j_dUv09jH7jsUJw", name: "Humberto Matos"},
%{youtube_id: "UC4aiJNDUviw_vMhdCq5Kq1Q", name: "Cortes do Casimito [OFICIAL]"},
%{youtube_id: "UC28n0tlcNSa1iPe5mettocg", name: "voidzilla"},
%{youtube_id: "UC2PA-AKmVpU6NKCGtZq_rKQ", name: "Philosophy Tube"}
  ]

  def sync do
    @channels
    |> Enum.map(&Subscriptions.get_all_content/1)
    |> Enum.flat_map(fn
      {:ok, entries} -> entries
      _ -> []
    end)
    |> Enum.sort_by(& &1.updated, {:desc, Date})
    |> Enum.slice(0, 20)
  end
end
