#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'


/*/{Protheus.doc} User Function AluMvc
    Mvc referente aos instrutores
    @type  Function
    @author Vin�cius Silva
    @since 27/03/2023
/*/
User Function AluMvc()
    Local cAlias := "ZZE"
    Local cTitle := "Cadastro de Alunos"
    Local oMark   := FwMarkBrowse():New()

    oMark:SetAlias(cAlias)
    oMark:SetDescription(cTitle)
    oMark:SetFieldMark("ZZE_MARC")

    oMark:AddButton("Excluir Marcados", "U_Deleta"  , 5, 1)

    oMark:DisableDetails()
    oMark:DisableReport()
    oMark:Activate()
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.AluMvc" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.AluMvc" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.AluMvc" OPERATION 5 ACCESS 0
    
Return aRotina

Static Function ModelDef()
    //? Valida��es do Modelo
    Local bModelPos := {|oModel| VldAul(oModel)}

    Local oModel   := MPFormModel():New("AluMvc_M", , bModelPos)
    Local oStruZZE := FWFormStruct(1, "ZZE")

    oModel:AddFields("ZZEMASTER",,oStruZZE)
    oStruZZE:SetProperty("ZZE_CODIGO", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  "GETSXENUM('ZZE', 'ZZE_CODIGO')"))

    oModel:SetPrimaryKey({"ZZE_CODIGO"})

Return oModel

Static Function ViewDef()
    Local oModel   := FwLoadModel("AluMvc") 
    Local oStruZZE := FWFormStruct(2, "ZZE")
    Local oView    := FwFormView():New()

    oView:SetModel(oModel) 
    oView:AddField("VIEW_ZZE", oStruZZE, "ZZEMASTER")
    oView:CreateHorizontalBox("Tela", 100)
    oView:SetOwnerView("VIEW_ZZE", "Tela")

Return oView

User Function Deleta()
    if MsgYesNo("Voc� deseja fazer a exclus�o desse aluno?")
        DbSelectArea("ZZE")

        ZZE->(DbGoTop())

        while ZZE->(!EOF())
            if ZZE_AULA == "N�o"
                if oMark:IsMark()
                    RecLock("ZZE", .F.)
                        ZZE->(DbDelete())
                    ZZE->(MsUnlock())
                endif 
            elseif ZZE_AULA == "Sim"
                Help(Nil, Nil, "N�o autorizado!", Nil, "Esse aluno ainda est� tendo aulas", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere o aluno encerrar as aulas."}) 
            endif 
            ZZE->(DbSkip())
        end
    endif

    oMark:Refresh(.T.)
Return 

Static Function VldAul(oModel)
    //? Variaveis para trabalhar com as incrementa��es da quant de alunos
    Local lRet     := .T.
    LocaL lAluMax  := .F.
    Local nOper    := oModel:GetOperation()
    Local cCodInst := oModel:GetValue("ZZEMASTER", "ZZE_CODINS")
    
    //? Vari�veis para valida��o do instrutor n�o preenchido 
    Local cTemInst := AllTrim(oModel:GetValue("ZZEMASTER", "ZZE_CODINS"))
    Local cTemAula := AllTrim(oModel:GetValue("ZZEMASTER", "ZZE_AULA"))    

    //? Parte para fazer as incrementa��es da quantidade de alunos
    DbSelectArea("ZZI")
    ZZI->(DbGoTop())
    while ZZI->(!EOF())
        if AllTrim(ZZI_CODIGO) == cCodInst 
            if nOper == 3 
                RecLock("ZZI", .F.)
                    ZZI -> ZZI_QUANTA += 1 
                ZZI->(MsUnlock())

                //? para validar se o instrutor tem ou n�o 5 alunos
                if ZZI_QUANTA >= 5
                    lRet := .F.
                    lAluMax := .T.
                    Help(Nil, Nil, "N�o autorizado!", Nil, "Esse instrutor j� tem alunos suficientes", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere o instrutor finalizar algumas aulas."})
                endif
            elseif nOper == 5 
                RecLock("ZZI", .F.)
                    ZZI -> ZZI_QUANTA -= 1   
                ZZI->(MsUnlock())
            endif
        endif
        ZZI->(DbSkip())  
    end       

    //? para valida��o do instrutor n�o preenchido
    if nOper == 3 
        if Empty(cTemInst) .AND. cTemAula == "Sim" 
            lRet := .F.
            Help(Nil, Nil, "N�o autorizado!", Nil, "� necess�rio selecionar um instrutor", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe qual � o seu instrutor."})
        elseif lAluMax .AND. cTemAula == "Sim"
            //? para validar se j� tem alunos suficientes o campo tem aula n�o pode ser sim
            lRet := .F.
            Help(Nil, Nil, "N�o autorizado!", Nil, "Esse instrutor j� tem aulas suficientes", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere ele encerrar as aulas."})
        endif 
    endif

    //? Impede de excluir com a op��o 5
    if nOper == 5 .AND. cTemAula == "Sim"
        lRet := .F.
        Help(Nil, Nil, "N�o autorizado!", Nil, "Esse aluno ainda est� tendo aulas", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere o aluno encerrar as aulas."}) 
    endif

Return lRet
