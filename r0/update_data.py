import json
import datetime
import pandas as pd
from sodapy import Socrata

client = Socrata("www.datos.gov.co", "tLEFpGcWvrqyQpLsbuPvmYD1c") 
results = client.get("gt2j-8ykr", limit=int(1e9))
df_ins = pd.DataFrame.from_records(results)

df_ins["fecha_reporte_web"] = pd.to_datetime(df_ins["fecha_reporte_web"], errors="coerce")
df_ins = df_ins[df_ins["fecha_reporte_web"]<datetime.datetime.today()]
df_ins["c_digo_divipola"] = df_ins["c_digo_divipola"].str.zfill(5)
df_ins["divipola_depto"] = df_ins["c_digo_divipola"].str[:-3]


div_mpio = df_ins["c_digo_divipola"].unique()
div_depto = df_ins["divipola_depto"].unique()

def place_data(df_place):
    # desde el primer notificado en el lugar hasta la ultima fecha de la ins

    idx = pd.date_range(df_place["fecha_reporte_web"].min(), df_ins["fecha_reporte_web"].max())
    all_dates = pd.DataFrame(idx, columns=["fecha"]).set_index("fecha")
    
    df_diag = df_place.groupby("fecha_reporte_web").size().to_frame("cuenta").rename_axis("fecha")
    df_fall = df_place.groupby("fecha_de_muerte").size().to_frame("cuenta_fallecidos").rename_axis("fecha")
    df_rec = df_place.groupby("fecha_recuperado").size().to_frame("cuenta_recuperados").rename_axis("fecha")
    
    df_all = all_dates.merge(df_diag, how="left", left_index=True, right_index=True)\
                      .merge(df_fall,how="left", left_index=True, right_index=True)\
                      .merge(df_rec,how="left", left_index=True, right_index=True).fillna(0).cumsum()
    return df_all


def get_output(df_all, names):
    return {
        "name": ' / '.join(names),
        "Y": [int(x) for x in list(df_all["cuenta"].values)],
        "t0": (df_all.index.astype(int) / 10**9)[0]
    }


dicc_output = {}

dicc_output['co'] = get_output(place_data(df_ins), ['Colombia'])

for depto in div_depto:
    df_depto = df_ins[df_ins["divipola_depto"] == depto]
    try:
        dpto = df_depto['departamento'].unique()

        if len(dpto)>1:
            print('More than 1 of: ')
            print(dpto)

        names = [dpto[0]]
        dicc_output['co_{}'.format(depto)] = get_output(place_data(df_depto), names)
    except Exception as e:
        print(depto,e)
        continue

for mun in div_mpio:
    df_ciudad = df_ins[df_ins["c_digo_divipola"] == mun]
    try:
        dpto = df_ciudad['departamento'].unique()
        mpio = df_ciudad['ciudad_de_ubicaci_n'].unique()

        if len(dpto)>1 or len(mpio)>1:
            print('More than 1 of: ')
            print(dpto,mpio)

        names = [mpio[0],dpto[0]]
        dicc_output['co_{}'.format(mun)] = get_output(place_data(df_ciudad), names)
    except Exception as e:
        print(mun,e)
        continue
    

with open('data/colombia.json', 'w') as outfile:
    json.dump(dicc_output, outfile)
    