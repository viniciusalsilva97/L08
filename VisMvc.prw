#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'

/*/{Protheus.doc} User Function nomeFunction
    Mvc para mostrar as tabelas conectadas
    @type  Function
    @author Vinicius Silva
    @since 28/03/2023
/*/
User Function VisMvc()
    Local cAlias  := "ZZH"
    Local cTitle  := "Cadastro de Categoria da CNH"
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)
    oBrowse:DisableDetails()
    oBrowse:DisableReport()
    oBrowse:Activate()
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.VisMvc" OPERATION 2 ACCESS 0

Return aRotina

Static Function ModelDef()
    Local oModel   := MpFormModel():New("MYMVC")
    Local oStruZZH := FwFormStruct(1, "ZZH")
    Local oStruZZI := FwFormStruct(1, "ZZI")
    Local oStruZZE := FwFormStruct(1, "ZZE")

    oModel:AddFields("ZZHMASTER", Nil, oStruZZH)
    oModel:SetDescription("Categoria da CNH")

    oModel:AddGrid("ZZIDETAIL", "ZZHMASTER", oStruZZI)

    oModel:AddGrid("ZZEDETAIL", "ZZIDETAIL", oStruZZE)

    oModel:SetRelation("ZZIDETAIL", {{"ZZI_FILIAL", "xFilial('ZZI')"}, {"ZZI_CATE", "ZZH_CODIGO"}}, ZZI->(IndexKey(1)))
    
    oModel:SetRelation("ZZEDETAIL", {{"ZZE_FILIAL", "xFilial('ZZE')"}, {"ZZE_CODINS", "ZZI_CODIGO"}}, ZZE->(IndexKey(1)))

    oModel:SetPrimaryKey({"ZZH_CODIGO", "ZZE_CODIGO", "ZZI_CODIGO"})

Return oModel 

Static Function ViewDef()
    Local oModel   := FwLoadModel("VisMvc")
    Local oStruZZH := FwFormStruct(2, "ZZH")
    Local oStruZZI := FwFormStruct(2, "ZZI")
    Local oStruZZE := FwFormStruct(2, "ZZE")
    Local oView    := FwFormView():New()

    oView:SetModel(oModel)

    oView:AddField("VIEW_ZZH", oStruZZH, "ZZHMASTER")
    oView:CreateHorizontalBox("TelaProd", 40)
    oView:SetOwnerView("VIEW_ZZH", "TelaProd")
    OView:EnableTitleView("VIEW_ZZH", "Categoria CNH")

    oView:AddGrid("VIEW_ZZI", oStruZZI, "ZZIDETAIL")
    oView:CreateHorizontalBox("TelaFormProd", 30)
    oView:SetOwnerView("VIEW_ZZI", "TelaFormProd")
    OView:EnableTitleView("VIEW_ZZI", "Instrutores")

    oView:AddGrid("VIEW_ZZE", oStruZZE, "ZZEDETAIL")
    oView:CreateHorizontalBox("GridProd", 30)
    oView:SetOwnerView("VIEW_ZZE", "GridProd")
    oView:EnableTitleView("VIEW_ZZE", "Alunos da Auto Escola")

Return oView
